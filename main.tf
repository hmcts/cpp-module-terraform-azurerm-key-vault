data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key-vault" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  public_network_access_enabled   = var.public_network_access_enabled
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  purge_protection_enabled        = var.purge_protection_enabled
  enable_rbac_authorization       = var.enable_rbac_authorization
  soft_delete_retention_days      = var.soft_delete_retention_days
  tags                            = var.tags

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }
}

resource "random_password" "passwd" {
  for_each    = { for k, v in coalesce(var.secrets, {}) : k => v if v == "" }
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  min_special = 4

  keepers = {
    name = each.key
  }
}

resource "azurerm_key_vault_secret" "keys" {
  for_each     = { for k, v in coalesce(var.secrets, {}) : k => v if v == "" }
  name         = each.key
  value        = each.value != "" ? each.value : random_password.passwd[each.key].result
  key_vault_id = azurerm_key_vault.key-vault.id

  lifecycle {
    ignore_changes = [
      tags,
      value,
    ]
  }
}

data "azurerm_private_dns_zone" "dns_kv" {
  count               = var.enable_data_lookup ? 1 : 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.private_dns_resource_group_name

}

data "azurerm_private_dns_zone" "dns_external" {
  for_each            = var.external_private_endpoint_map
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = each.value.private_dns_resource_group_name
}

data "azurerm_subnet" "external_subnet" {
  for_each             = var.external_private_endpoint_map
  name                 = each.value.subnet_name
  virtual_network_name = each.key
  resource_group_name  = each.value.vnet_resource_group_name
}

resource "azurerm_private_endpoint" "endpoint-vault" {
  count               = var.public_network_access_enabled ? 0 : 1
  name                = "${var.name}-vault-pvt"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_kv

  private_service_connection {
    name                           = "keyvault-privatelink"
    private_connection_resource_id = azurerm_key_vault.key-vault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "dns-zone-group-kv"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dns_kv[0].id]
  }
  tags = var.tags
}

resource "azurerm_private_endpoint" "external_endpoint_vault" {
  for_each            = var.external_private_endpoint_map
  name                = "${var.name}-${each.value.subnet_name}-${each.value.private_dns_resource_group_name}-vault-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = lookup(each.value, "external_subnet_id", data.azurerm_subnet.external_subnet[each.key].id)

  private_service_connection {
    name                           = "${var.name}-${each.value.subnet_name}-${each.value.private_dns_resource_group_name}-psc"
    private_connection_resource_id = azurerm_key_vault.key-vault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.name}-${each.value.private_dns_resource_group_name}-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dns_external[each.key].id]
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "keyvault_group_role_assignment" {
  for_each = { for i, policy in var.rbac_policy : i => policy }

  principal_id         = each.value.principal_id
  scope                = azurerm_key_vault.key-vault.id
  role_definition_name = each.value.role_definition_name
}
