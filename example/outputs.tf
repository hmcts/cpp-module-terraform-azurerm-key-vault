output "id" {
  description = "The ID of the Key Vault."
  value       = element(values(module.key-vault).*.id, 0)
}

output "name" {
  description = "Name of key vault created."
  value       = element(values(module.key-vault).*.name, 0)
}

output "vault_uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
  value       = values(module.key-vault).*.vault_uri
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}
