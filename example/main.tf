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

#data "azuread_service_principal" "adspn" {
#  count        = length(var.access_policy.azure_ad_service_principal_names)
#  display_name = var.access_policy.azure_ad_service_principal_names[count.index]
#}

module "key-vault" {
  for_each                        = local.combined_rbac_policies
  source                          = "../"
  name                            = each.key
  location                        = var.location
  resource_group_name             = azurerm_resource_group.test.name
  tenant_id                       = each.value.tenant_id
  sku_name                        = each.value.sku_name
  public_network_access_enabled   = each.value.public_network_access_enabled
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_deployment          = each.value.enabled_for_deployment
  purge_protection_enabled        = each.value.purge_protection_enabled
  soft_delete_retention_days      = each.value.soft_delete_retention_days
  rbac_policy                     = each.value.rbac_policy
  tags                            = module.tag_set.tags
}
