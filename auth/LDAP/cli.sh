vault auth enable ldap

vault write auth/ldap/config \
url="ldap://<ldap_server_ip>" \
binddn="CN=service_account,OU=OrgUnit,DC=domain,DC=root_domain" \
bindpass="password" \
userdn="DC=domain,DC=root_domain" \
userattr="sAMAccountName" \
groupdn="OU=OrgUnit,DC=domain,DC=root_domain" \
groupattr="cn" \
userfilter="(&({{.UserAttr}}={{.Username}})(|
(memberOf=CN=groupCN,OU=OrgUnit,DC=domain,DC=root_domain)
(memberOf=CN=group1,OU=OrgUnit,DC=domain,DC=root_domain)
(memberOf=CN=group2,OU=OrgUnit,DC=domain,DC=root_domain)
))"


vault login -method=ldap username=<username>