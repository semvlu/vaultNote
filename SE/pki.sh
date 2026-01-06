vault secret enable pki

# Gen CA cert & key
vault write pki/root/generate/internal common_name=example.com

# Set URLs for CA and CRL
vault write pki/config/urls \
  issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
  crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"

# Check CA
vault read pki/cert/ca # CA cert
vault read pki/issuer
vault read pki/issuer/<issuer_id>/json

# ---

# Config a role to issue certs for example.com
vault write pki/roles/example-dot-com \ 
  allowed_domains=example.com \
  allow_subdomains=true \
  max_ttl=72h
# Issue cert for www.example.com
vault write pki/issue/example-dot-com common_name=www.example.com
