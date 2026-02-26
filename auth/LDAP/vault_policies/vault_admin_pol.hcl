path "auth/token/lookup-self" {
    capabilities = ["read"]
}

path "secret/foo/" {
    capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}

path "secret/foo/*" {
    capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}