locals {

  key_vault_attributes = {
    for kv_name, kv_config in var.key_vaults : kv_name => {
      tenant_id                       = kv_config.tenant_id
      sku_name                        = kv_config.sku_name
      public_network_access_enabled   = kv_config.public_network_access_enabled
      enabled_for_template_deployment = coalesce(kv_config.enabled_for_template_deployment, false)
      purge_protection_enabled        = coalesce(kv_config.purge_protection_enabled, false)
      soft_delete_retention_days      = kv_config.soft_delete_retention_days
      enable_rbac_authorization       = coalesce(kv_config.enable_rbac_authorization, false)
      enabled_for_deployment          = coalesce(kv_config.enabled_for_deployment, false)
      enabled_for_disk_encryption     = coalesce(kv_config.enabled_for_disk_encryption, false)
      network_acls                    = kv_config.network_acls
      secrets                         = kv_config.secrets
      rbac_policy = [
        for rbac_policy in kv_config.rbac_policy : {
          azure_ad_group_names             = coalesce(rbac_policy.azure_ad_group_names, [])
          azure_ad_user_principal_names    = coalesce(rbac_policy.azure_ad_user_principal_names, [])
          azure_ad_service_principal_names = coalesce(rbac_policy.azure_ad_service_principal_names, [])
          role_definition_name             = rbac_policy.role_definition_name
        }
      ]
    }
  }


  azure_ad_group_names             = distinct(flatten([for kv_config in values(local.key_vault_attributes) : kv_config.rbac_policy[*].azure_ad_group_names]))
  azure_ad_user_principal_names    = distinct(flatten([for kv_config in values(local.key_vault_attributes) : kv_config.rbac_policy[*].azure_ad_user_principal_names]))
  azure_ad_service_principal_names = distinct(flatten([for kv_config in values(local.key_vault_attributes) : kv_config.rbac_policy[*].azure_ad_service_principal_names]))


  group_object_ids = { for g in data.azuread_group.adgrp : lower(g.display_name) => g.id }
  user_object_ids  = { for u in data.azuread_user.adusr : lower(u.user_principal_name) => u.id }
  spn_object_ids   = { for s in data.azuread_service_principal.adspn : lower(s.display_name) => s.id }


  flattened_rbac_policies = {
    for kv_name, kv_config in local.key_vault_attributes : kv_name => concat(
      flatten([
        for rbac_policy in kv_config.rbac_policy : flatten([
          for n in rbac_policy.azure_ad_group_names : {
            object_id            = local.group_object_ids[lower(n)]
            role_definition_name = rbac_policy.role_definition_name
          }
        ])
      ]),
      flatten([
        for rbac_policy in kv_config.rbac_policy : flatten([
          for n in rbac_policy.azure_ad_user_principal_names : {
            object_id            = local.user_object_ids[lower(n)]
            role_definition_name = rbac_policy.role_definition_name
          }
        ])
      ]),
      flatten([
        for rbac_policy in kv_config.rbac_policy : flatten([
          for n in rbac_policy.azure_ad_service_principal_names : {
            object_id            = local.spn_object_ids[lower(n)]
            role_definition_name = rbac_policy.role_definition_name
          }
        ])
      ])
    )
  }



  combined_rbac_policies = {
    for kv_name, policies in local.flattened_rbac_policies : kv_name => {
      tenant_id                       = local.key_vault_attributes[kv_name].tenant_id
      sku_name                        = local.key_vault_attributes[kv_name].sku_name
      public_network_access_enabled   = local.key_vault_attributes[kv_name].public_network_access_enabled
      enabled_for_template_deployment = local.key_vault_attributes[kv_name].enabled_for_template_deployment
      purge_protection_enabled        = local.key_vault_attributes[kv_name].purge_protection_enabled
      soft_delete_retention_days      = local.key_vault_attributes[kv_name].soft_delete_retention_days
      enable_rbac_authorization       = local.key_vault_attributes[kv_name].enable_rbac_authorization
      enabled_for_deployment          = local.key_vault_attributes[kv_name].enabled_for_deployment
      enabled_for_disk_encryption     = local.key_vault_attributes[kv_name].enabled_for_disk_encryption
      secrets                         = local.key_vault_attributes[kv_name].secrets
      network_acls                    = local.key_vault_attributes[kv_name].network_acls
      rbac_policy = {
        for policy in policies : policy.object_id => {
          role_definition_name = policy.role_definition_name
        }
      }
    }
  }

  tier            = "data"
  application     = "keyvaults"
  type            = "keyvaults"
  owner           = "HMCTS-SP"
  creator         = "SPT/terraform"
  expiration_date = "none"

  tags = module.tag_set.tags

}

data "azuread_group" "adgrp" {
  count        = length(local.azure_ad_group_names)
  display_name = local.azure_ad_group_names[count.index]
}

data "azuread_user" "adusr" {
  count               = length(local.azure_ad_user_principal_names)
  user_principal_name = local.azure_ad_user_principal_names[count.index]
}

data "azuread_service_principal" "adspn" {
  count        = length(local.azure_ad_service_principal_names)
  display_name = local.azure_ad_service_principal_names[count.index]
}
