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


resource "azurerm_key_vault" "key-vault" {
  name                            = var.key-vault-name
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
}
