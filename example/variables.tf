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


variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled"
  type        = bool
}

variable "enable_data_lookup" {
  type    = bool
  default = false
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


variable "purge_protection_enabled" {
  type    = bool
  default = false
}

variable "soft_delete_retention_days" {
  type    = number
  default = 1
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
  default     = ""
}

variable "access_policies" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "access_policy" {
  description = "List of access policies for the Key Vault."
  default     = []
}
