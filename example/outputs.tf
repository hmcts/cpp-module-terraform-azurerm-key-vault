output "id" {
  description = "The ID of the Key Vault."
  value       = module.key-vault.id
}

output "name" {
  description = "Name of key vault created."
  value       = module.key-vault.name
}

output "vault_uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
  value       = module.key-vault.vault_uri
}

#output "secrets" {
#  description = "A mapping of secret names and URIs."
#  value       = { for k, v in azurerm_key_vault_secret.keys : v.name => v.id }
#}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}
