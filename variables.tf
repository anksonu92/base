variable "resource_group_name" {
  description = "The name of the resource group where modules resources will be deployed. The resource group location will be used for all resources in this module as well."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}

variable "key_vault" {
  description = "The key vault configuration used for all LENS-related certificate and key storage. Note there are two access models: 'rbac' and 'policy'. RBAC is preferred, but requires the user or service principal who is running Terraform to be assigned at minimum 'Owner' role on the Resource Group where LENS is deployed (Subscription Owner role would work as well as it would be inherited by the Resource Group)."
  type = object({
    name         = string
    access_model = string # "rbac" or "policy"
    access_policies = map(object({
      object_id               = string
      certificate_permissions = list(string)
      key_permissions         = list(string)
      secret_permissions      = list(string)
    }))
    rbac_roles = map(object({
      object_id            = string
      role_definition_name = string
    }))
  })
  default = {
    name            = "lens-kv"
    access_model    = "rbac"
    access_policies = {}
    rbac_roles      = {}
  }

  validation {
    condition = (
      length(var.key_vault.name) <= 19 && length(var.key_vault.name) >= 3 &&
      length(regexall("[^\\w-]", var.key_vault.name)) == 0 &&
      contains(["policy", "rbac"], var.key_vault.access_model) &&
      can(var.key_vault.access_model == "rbac" ?
        (
          can({ for k, v in var.key_vault.rbac_roles : k => contains([
            "Key Vault Administrator",
            "Key Vault Reader",
            "Key Vault Certificate Officer",
            "Key Vault Crypto Officer",
            "Key Vault Crypto User",
            "Key Vault Crypto Service Encryption User",
            "Key Vault Secrets Officer",
            "Key Vault Secrets User"
          ], v.role_definition_name) if length(var.key_vault.rbac_roles) > 0 })
        ) : true
      ) &&
      can(var.key_vault.access_model == "policy" ?
        (
          can({ for k, v in var.key_vault.access_policies : k => contains([
            "Backup",
            "Create",
            "Delete",
            "DeleteIssuers",
            "Get",
            "GetIssuers",
            "Import",
            "List",
            "ListIssuers",
            "ManageContacts",
            "ManageIssuers",
            "Purge",
            "Recover",
            "Restore",
            "SetIssuers",
            "Update"
          ], v.certificate_permissions) if length(var.key_vault.access_policies) > 0 }) &&
          can({ for k, v in var.key_vault.access_policies : k => contains([
            "Backup",
            "Create",
            "Decrypt",
            "Delete",
            "Encrypt",
            "Get",
            "Import",
            "List",
            "Purge",
            "Recover",
            "Restore",
            "Sign",
            "UnwrapKey",
            "Update",
            "Verify",
            "WrapKey"
          ], v.key_permissions) if length(var.key_vault.access_policies) > 0 }) &&
          can({ for k, v in var.key_vault.access_policies : k => contains([
            "Backup",
            "Delete",
            "Get", "List",
            "Purge",
            "Recover",
            "Restore",
            "Set"
          ], v.secret_permissions) if length(var.key_vault.access_policies) > 0 })
        ) : true
      )
    )
    error_message = "Please check your var.key_vault object to ensure compatibility."
  }
}

variable "tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    Team        = "analytics",
    Application = "analytics",
    Department  = "it"
  }
}

variable "datalake" {
  description = "Details of Storage Account DataLake to create. Note there are two access models: 'rbac' and 'sas'. RBAC is preferred, but requires the user or service principal who is running Terraform to be assigned at minimum 'Owner' role on the Resource Group where LENS is deployed (Subscription Owner role would work as well as it would be inherited by the Resource Group)."
  type = object({
    name                   = string
    tier                   = string
    replication_type       = string
    data_retention_in_days = number
    containers             = list(string)
    access_model           = string # "rbac" or "sas"
    rbac_roles = map(object({
      object_id            = string
      role_definition_name = string
    }))
  })
  default = {
    name                   = "lensdatalake"
    tier                   = "Standard"
    replication_type       = "LRS"
    data_retention_in_days = 7
    containers = [
      "dropzone",
      "raw",
      "stage",
      "mdw"
    ]
    access_model = "rbac"
    rbac_roles   = {}
  }

  validation {
    condition = (
      length(var.datalake.name) <= 19 &&
      length(var.datalake.name) >= 3 &&
      length(regexall("[^\\w]", var.datalake.name)) == 0 &&
      contains(["sas", "rbac"], var.datalake.access_model) &&
      can(var.datalake.access_model == "rbac" ?
        (
          can({ for k, v in var.datalake.rbac_roles : k => contains([
            "Storage Blob Data Reader",
            "Storage Blob Data Contributor",
            "Storage Blob Data Owner"
          ], v.role_definition_name) if length(var.datalake.rbac_roles) > 0 })
        ) : true
      )
    )
    error_message = "Please check your var.datalake object to ensure compatibility."
  }
}

variable "rbac_propagation_await_time" {
  description = "The time to await for RBAC role assignment propagation. Varies by region! We await RBAC propagation because the AzureRM API returns 200 for role assignments before they've propagated and gives no async way to monitor."
  type        = string
  default     = "8m"
}
