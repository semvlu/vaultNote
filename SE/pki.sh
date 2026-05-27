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
  
vault write pki/roles/kube-certs \
    issuer_ref="<issuer_id>" \
    allowed_domains="local,argocd.local,minio.local,vault.local" \
    allow_subdomains=true \
    allow_bare_domains=true \
    max_ttl="720h"
    
# Issue cert for www.example.com
vault write pki/issue/example-dot-com common_name=www.example.com

# --- Kubernetes Root CA exp issue ---
# GW port FW 443 fail fix: CA issuer 
vault secrets tune -max-lease-ttl=87600h pki # 10 yr

# Gen Root CA
vault write pki/root/generate/internal \
    common_name="cluster.local" \
    issuer_name="root-CA" \
    ttl=87600h

# Set default issuer
vault write pki/config/issuers default="<ISSUER-UUID>"

# Allow subdomains
vault write pki/roles/kube-certs \
    allowed_domains="local" \
    allow_subdomains=true \
    issuer_ref="default"

# Force cert-manager to fetch new cert
kubectl delete certificate gateway-tls-cert -n envoy-gateway-system
kubectl apply -f gateway-cert.yaml

# Delete old Root CA
vault delete pki/issuer/<OLD-ISSUER-UUID>
