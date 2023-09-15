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
  access_policy = [{
    tenant_id               = data.azurerm_client_config.current.tenant_id
    object_id               = data.azurerm_client_config.current.object_id
    secret_permissions      = ["Get", "List"]
    certificate_permissions = []
    key_permissions         = []
    storage_permissions     = []
  }]

}
