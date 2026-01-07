# Client key signing: 
vault secrets enable -path=ssh-client-signer ssh

# Gen CA
vault write ssh-client-signer/config/ca generate_signing_key=true
# If already have a keypair:
vault write ssh-client-signer/config/ca \
    private_key="..." \
    public_key="..."

# @ Host Machine
# Add public key to target hosts' SSH config,
curl -o /etc/ssh/<ca-keys>.pem \
    https://vault.corp.example.com:8200/v1/ssh-client-signer/public_key
    # /public_key endpoint does not need auth

vault read -field=public_key ssh-client-signer/config/ca > /etc/ssh/<ca-keys>.pem
# `/etc/ssh/sshd_config`
TrustedUserCAKeys /etc/ssh/<ca-keys>

# Config a role for signing 
vault write ssh-client-signer/roles/my-role -<<"EOH"
{
  "algorithm_signer": "rsa-sha2-256",
  "allow_user_certificates": true,
  "allowed_users": "*",
  "allowed_extensions": "permit-pty,permit-port-forwarding", 
  "default_extensions": {
    "permit-pty": ""
  },
  "key_type": "ca",
  "default_user": "ubuntu",
  "ttl": "30m0s"
}
EOH
# permit-pty: enable interactive shell session

# Client SSH auth
ssh-keygen # gen id_rsa.pub
vault write ssh-client-signer/sign/my-role \
    public_key=@$HOME/.ssh/id_rsa.pub
# Save signed public key to disk
vault write -field=signed_key ssh-client-signer/sign/my-role \
    public_key=@$HOME/.ssh/id_rsa.pub > id_rsa-cert.pub
ssh -i signed-cert.pub -i ~/.ssh/id_rsa <username>@<ip>

# ---

# Host key signing: extra layer sec.
    # SSH agent verify target host is valid & trusted before SSH acc.
    # Reduce accidental SSH acc. into unmanaged / malicious machines.

# Mount host key signing @ diff. path
vault secrets enable -path=ssh-host-signer ssh
# Gen CA, vide supra: config/ca

# Extend host key cert TTL, TTL is for signed cert
vault secrets tune -max-lease-ttl=3650d ssh-host-signer

# Config a role, remember allowed_domains
vault write ssh-host-signer/roles/hostrole \
    key_type=ca \
    algorithm_signer=rsa-sha2-256 \
    ttl=87600h \
    allow_host_certificates=true \
    allowed_domains="localdomain,example.com" \
    allow_subdomains=true

# Sign SSH host public key
vault write ssh-host-signer/sign/hostrole \
    cert_type=host \
    public_key=@/etc/ssh/ssh_host_rsa_key.pub
# @ Host machine
# --- 
vault write -field=signed_key ssh-host-signer/sign/hostrole \
    cert_type=host \
    public_key=@/etc/ssh/ssh_host_rsa_key.pub > /etc/ssh/ssh_host_rsa_key-cert.pub
chmod 0640 /etc/ssh/ssh_host_rsa_key-cert.pub
# ---
# `/etc/ssh/sshd_config`
HostKey /etc/ssh/ssh_host_rsa_key
HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub

# Verify @ client
vault read -field=public_key ssh-host-signer/config/ca
# Add public to `known_hosts`
# `known_hosts`
@cert-authority *.example.com ssh-rsa AAAAB3NzaC1yc2EAAA...


:'
Client Key Signing
    CA key pair: vault, public key distributed to target
    Client SSH key pair: client
    Signed cert: client
    Login: Target holds CA public key to check client cert

Host (Target) Key Signing
    CA key pair : vault, public key distributed to client
    Host SSH key pair: target
    Host cert: target
    Login: Client holds CA public key to check target cert
'
