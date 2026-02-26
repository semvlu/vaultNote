locals {
  vault_groups = [
    "vault_admin",
    "vault_group1",
    "vault_group2",
    "vault_group3",
  ]
}

resource "vault_policy" "group_policies" {
  for_each = toset(local.vault_groups)

  name   = each.key
  policy = file("vault_policies/${each.key}_pol.hcl")
}
