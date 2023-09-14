data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

module "tag_set" {
  source         = "git::https://github.com/hmcts/cpp-module-terraform-azurerm-tag-generator.git?ref=main"
  namespace      = var.namespace
  application    = var.application
  costcode       = var.costcode
  owner          = var.owner
  version_number = var.version_number
  attribute      = var.attribute
  environment    = var.environment
  type           = var.type
}

resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = var.location
  tags     = module.tag_set.tags
}

data "azuread_service_principal" "adspn" {
  count        = length(var.access_policy.azure_ad_service_principal_names)
  display_name = var.access_policy.azure_ad_service_principal_names[count.index]
}

module "key-vault" {
  source                          = "../"
  name                            = var.name
  location                        = var.location
  resource_group_name             = azurerm_resource_group.test.name
  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  public_network_access_enabled   = var.public_network_access_enabled
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days
  tags                            = module.tag_set.tags

  #  dynamic "network_acls" {
  #    for_each = var.network_acls != null ? [true] : []
  #    content {
  #      bypass                     = var.network_acls.bypass
  #      default_action             = var.network_acls.default_action
  #      ip_rules                   = var.network_acls.ip_rules
  #      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
  #    }
  #  }
  access_policy = [
    {
      tenant_id          = data.azurerm_client_config.current.tenant_id
      object_id          = { for s in data.azuread_service_principal.adspn : lower(s.display_name) => s.id }
      secret_permissions = ["get", "list"]
    }
  ]
}

resource "random_password" "passwd" {
  for_each    = { for k, v in var.secrets : k => v if v == "" }
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
  for_each     = var.secrets
  name         = each.key
  value        = each.value != "" ? each.value : random_password.passwd[each.key].result
  key_vault_id = module.key-vault.id

  lifecycle {
    ignore_changes = [
      tags,
      value,
    ]
  }
}
