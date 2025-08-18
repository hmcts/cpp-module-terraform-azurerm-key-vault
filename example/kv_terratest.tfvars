key_vaults = {
  KV-TEST-2t-LAB-Terratest = {
    tenant_id                       = "e2995d11-9947-4e78-9de6-d44e0603518e"
    sku_name                        = "standard"
    public_network_access_enabled   = true
    enabled_for_template_deployment = true
    soft_delete_retention_days      = 7
    enable_data_lookup              = false
    enable_rbac_authorization       = true
    purge_protection_enabled        = false
    rbac_policy = [{
      azure_ad_service_principal_names = [
        "test-spn-1",
        "test-spn-2",
      ],
      azure_ad_group_names = [
        "test-group-1",
        "test-group-2",
      ],
      azure_ad_user_principal_names = [
        "test-user-1",
        "test-user-2",
      ],
      role_definition_name = "Key Vault Administrator"
    }],
    network_acls = {
      bypass         = "AzureServices"
      default_action = "Deny"
    }
  }
}
