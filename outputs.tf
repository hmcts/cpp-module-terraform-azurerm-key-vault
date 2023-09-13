output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.key-vault.id
}

output "key_vault_name" {
  description = "Name of key vault created."
  value       = azurerm_key_vault.key-vault.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
  value       = azurerm_key_vault.key-vault.vault_uri
}