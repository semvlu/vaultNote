LDAP - Vault policy mapping: `users`, `groups`

```
vault auth enable ldap

vault write auth/ldap/config \
url="ldap://<LDAP_IP>" \
binddn="CN=<common_name>,OU=<Org>,DC=<sub-domain>,DC=<domain>" \
bindpass="<password>" \
userdn="DC=<sub-domain>,DC=<domain>" \
userattr="sAMAccountName" \
groupdn="OU=<Org>,DC=<sub-domain>,DC=<domain>" \
groupattr="cn" \
userfilter="(&({{.UserAttr}}={{.Username}})(|(memberOf=CN=<group>,OU=<Org>,DC=<sub-domain>,DC=<domain>)(memberOf=CN=<group>,OU=<Org>,DC=<sub-domain>,DC=<domain>)(memberOf=CN=<group>,OU=<Org>,DC=<sub-domain>,DC=<domain>)(memberOf=CN=<group>,OU=<Org>,DC=<sub-domain>,DC=<domain>)))"

# userattr="userPrincipalName"


vault write auth/ldap/groups/<group> policies=<policy>


vault login -method=ldap username=<username>
```

### Binding prms
Resolve user obj: Search 
- Search: `binddn`, `bindpass`
- `userattr`: set attribute object matching the username, e.g. sAMAccountName, cn, uid

### Add user to group
User instance -> Member Of -> Add

### Login method
- sAMAccountName
- userPrincipalName: full domain account name

Check: User instance -> Attribute Editor