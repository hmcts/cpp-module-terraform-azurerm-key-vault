
#locals {
#  access_policies = [
#    for p in var.access_policies : merge({
#      azure_ad_group_names             = []
#      object_ids                       = []
#      azure_ad_user_principal_names    = []
#      certificate_permissions          = []
#      key_permissions                  = []
#      secret_permissions               = []
#      storage_permissions              = []
#      azure_ad_service_principal_names = []
#    }, p)
#  ]
#
#  azure_ad_group_names             = distinct(flatten(local.access_policies[*].azure_ad_group_names))
#  azure_ad_user_principal_names    = distinct(flatten(local.access_policies[*].azure_ad_user_principal_names))
#  azure_ad_service_principal_names = distinct(flatten(local.access_policies[*].azure_ad_service_principal_names))
#
#  group_object_ids = { for g in data.azuread_group.adgrp : lower(g.display_name) => g.id }
#  user_object_ids  = { for u in data.azuread_user.adusr : lower(u.user_principal_name) => u.id }
#  spn_object_ids   = { for s in data.azuread_service_principal.adspn : lower(s.display_name) => s.id }
#
#  flattened_access_policies = concat(
#    flatten([
#      for p in local.access_policies : flatten([
#        for i in p.object_ids : {
#          object_id               = i
#          certificate_permissions = p.certificate_permissions
#          key_permissions         = p.key_permissions
#          secret_permissions      = p.secret_permissions
#          storage_permissions     = p.storage_permissions
#        }
#      ])
#    ]),
#    flatten([
#      for p in local.access_policies : flatten([
#        for n in p.azure_ad_group_names : {
#          object_id               = local.group_object_ids[lower(n)]
#          certificate_permissions = p.certificate_permissions
#          key_permissions         = p.key_permissions
#          secret_permissions      = p.secret_permissions
#          storage_permissions     = p.storage_permissions
#        }
#      ])
#    ]),
#    flatten([
#      for p in local.access_policies : flatten([
#        for n in p.azure_ad_user_principal_names : {
#          object_id               = local.user_object_ids[lower(n)]
#          certificate_permissions = p.certificate_permissions
#          key_permissions         = p.key_permissions
#          secret_permissions      = p.secret_permissions
#          storage_permissions     = p.storage_permissions
#        }
#      ])
#    ]),
#    flatten([
#      for p in local.access_policies : flatten([
#        for n in p.azure_ad_service_principal_names : {
#          object_id               = local.spn_object_ids[lower(n)]
#          certificate_permissions = p.certificate_permissions
#          key_permissions         = p.key_permissions
#          secret_permissions      = p.secret_permissions
#          storage_permissions     = p.storage_permissions
#        }
#      ])
#    ])
#  )
#
#  grouped_access_policies = { for p in local.flattened_access_policies : p.object_id => p... }
#
#  combined_access_policies = [
#    for k, v in local.grouped_access_policies : {
#      object_id               = k
#      certificate_permissions = distinct(flatten(v[*].certificate_permissions))
#      key_permissions         = distinct(flatten(v[*].key_permissions))
#      secret_permissions      = distinct(flatten(v[*].secret_permissions))
#      storage_permissions     = distinct(flatten(v[*].storage_permissions))
#    }
#  ]
#}
#
#
#
#data "azurerm_client_config" "current" {}
#
#data "azuread_group" "adgrp" {
#  count        = length(local.azure_ad_group_names)
#  display_name = local.azure_ad_group_names[count.index]
#}
#
#data "azuread_user" "adusr" {
#  count               = length(local.azure_ad_user_principal_names)
#  user_principal_name = local.azure_ad_user_principal_names[count.index]
#}
#
#data "azuread_service_principal" "adspn" {
#  count        = length(local.azure_ad_service_principal_names)
#  display_name = local.azure_ad_service_principal_names[count.index]
#}

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
  soft_delete_retention_days      = var.soft_delete_retention_days
  tags                            = var.tags

  dynamic "access_policy" {
    for_each = var.access_policy
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

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
  resource_group_name = "RG-MDV-INT-01"

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
