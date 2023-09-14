variable "location" {
  type    = string
  default = "uksouth"
}

variable "name" {
  type    = string
  default = ""
}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "tenant_id" {
  type    = string
  default = ""
}

variable "object_id" {
  type    = string
  default = ""
}

variable "subnet_kv" {
  description = "Subnet for key vault"
  type        = string
  default     = ""
}

variable "certificate_permissions" {
  type    = list(string)
  default = []
}

variable "key_permissions" {
  type    = list(string)
  default = []
}

variable "secret_permissions" {
  type = list(string)
  default = [
    "Set",
    "List",
    "Get",
    "Delete",
    "Recover",
    "Purge",
  ]
}

variable "sku_name" {
  type    = string
  default = ""
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "enabled_for_template_deployment" {
  type    = bool
  default = true
}

variable "enabled_for_disk_encryption" {
  type    = bool
  default = true
}

variable "enabled_for_deployment" {
  type    = bool
  default = true
}

variable "purge_protection_enabled" {
  type    = bool
  default = true
}

variable "soft_delete_retention_days" {
  type    = number
  default = 1
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "attribute" {
  type        = string
  description = "An attribute of the s3 bucket that makes it unique"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Environment into which resource is deployed"
  default     = ""
}

variable "network_acls" {
  description = "Network rules to apply to key vault."
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "enable_data_lookup" {
  type    = bool
  default = false
}

variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be an organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "costcode" {
  type        = string
  description = "Name of theDWP PRJ number (obtained from the project portfolio in TechNow)"
  default     = ""
}

variable "owner" {
  type        = string
  description = "Name of the project or sqaud within the PDU which manages the resource. May be a persons name or email also"
  default     = ""
}

variable "application" {
  type        = string
  description = "Application to which the s3 bucket relates"
  default     = ""
}

variable "secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault."
  default     = {}
}

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  default     = 32
}

variable "azure_ad_service_principal_names" {
  type        = string
  description = "Name of theDWP PRJ number (obtained from the project portfolio in TechNow)"
  default     = "ado_nonlive_service_principal_lab"
}

variable "access_policies" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "access_policy" {
  description = "List of access policies for the Key Vault."
  default     = []
}
