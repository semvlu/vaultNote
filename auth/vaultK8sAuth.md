# Vault Kubernetes Auth
Auth w/ Kubernetes Service Account Token.
Each Pod has its tk @ `/var/run/secrets/kubernetes.io/serviceaccount/`

## Setup
```
vault auth enable kubernetes

# Config 
vault write auth/kubernetes/config \
    token_reviewer_jwt="<reviewer service account JWT>" \
    kubernetes_host=https://192.168.99.100:< TCP port> \ # If port not set, default: 443
    kubernetes_ca_cert=@ca.crt

# Create Role
vault write auth/kubernetes/role/demo \
    bound_service_account_names=myapp \
    bound_service_account_namespaces=default \
    policies=default \
    audience=myapp \
    ttl=1h
```

If Vault qua Pod, use pod's local service account tk. Vault re-read file to support short-lived tk. 
- Omit `token_reviewer_jwt`, `kubernetes_ca_cert`.
- Vault load from `token`, `ca.crt` @ `/var/run/secrets/kubernetes.io/serviceaccount/`.

```
vault write auth/kubernetes/config \
    kubernetes_host=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
```

If Vault in K8s, `disable_local_ca_jwt=true`


```
vault write auth/kubernetes/login role=demo jwt=...
```
