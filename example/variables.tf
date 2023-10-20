variable "location" {
  type    = string
  default = "uksouth"
}

variable "sku_name" {
  type    = string
  default = ""
}

variable "name" {
  type    = string
  default = ""
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

variable "tenant_id" {
  type    = string
  default = ""
}

variable "object_id" {
  type    = string
  default = ""
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

variable "type" {
  type        = string
  description = "Name of service type"
  default     = ""
}

variable "version_number" {
  type        = string
  description = "The version of the application or object being deployed. This could be a build object or other artefact which is appended by a CI/Cd platform as part of a process of standing up an environment"
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-lab-cpp-saterratest"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "enable_data_lookup" {
  type    = bool
  default = false
}

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  default     = 32
}

variable "key_vaults" {
  type = map(object({
    tenant_id                       = optional(string)
    sku_name                        = string
    public_network_access_enabled   = bool
    enabled_for_template_deployment = bool
    enabled_for_disk_encryption     = optional(bool)
    enabled_for_deployment          = optional(bool)
    purge_protection_enabled        = bool
    soft_delete_retention_days      = number
    enable_rbac_authorization       = optional(bool)
    secrets                         = optional(map(string))
    network_acls = object({
      bypass                     = string
      default_action             = string
      ip_rules                   = optional(list(string))
      virtual_network_subnet_ids = optional(list(string))
    })
    rbac_policy = list(object({
      azure_ad_service_principal_names = optional(list(string))
      azure_ad_group_names             = optional(list(string))
      azure_ad_user_principal_names    = optional(list(string))
      role_definition_name             = optional(string)
    }))

  }))
  default     = {}
  description = "Configuration for key vault creation"
}
