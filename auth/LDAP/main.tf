provider "vault" {
  skip_tls_verify = true
}

resource "vault_ldap_auth_backend" "ldap" {
  path                = "ldap"
  url                 = "ldap://<ldap_server_ip>"
  binddn              = "CN=service_account,OU=OrgUnit,DC=domain,DC=root_domain"
  bindpass_wo         = var.srv_pass
  bindpass_wo_version = 1
  userdn              = "DC=domain,DC=root_domain"
  userattr            = "sAMAccountName"
  groupdn             = "OU=OrgUnit,DC=domain,DC=root_domain"
  groupattr           = "cn"

  userfilter = "(&({{.UserAttr}}={{.Username}})(|memberOf=CN=groupCN,OU=OrgUnit,DC=domain,DC=root_domain)(memberOf=CN=group1,OU=OrgUnit,DC=domain,DC=root_domain)(memberOf=CN=group2,OU=OrgUnit,DC=domain,DC=root_domain)))"
}

# Group - Policy Mapping
resource "vault_ldap_auth_backend_group" "vault_admin" {
  groupname = "vault admin"
  policies  = ["vault_admin_pol"]
  backend   = vault_ldap_auth_backend.ldap.path
}

resource "vault_ldap_auth_backend_group" "vault_group1" {
  groupname = "vault_group1"
  policies  = ["vault_group1_pol"]
  backend   = vault_ldap_auth_backend.ldap.path
}

resource "vault_ldap_auth_backend_group" "vault_group2" {
  groupname = "vault_group2"
  policies  = ["vault_group2_pol"]
  backend   = vault_ldap_auth_backend.ldap.path
}

resource "vault_ldap_auth_backend_group" "vault_group3" {
  groupname = "vault_group3"
  policies  = ["vault_group3_pol"]
  backend   = vault_ldap_auth_backend.ldap.path
}