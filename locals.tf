locals {
  key_vault = {
    implicit_rbac_roles = {
      current_principal = {
        object_id            = data.azurerm_client_config.current.object_id
        role_definition_name = "Key Vault Administrator"
      }
    }

    implicit_access_policies = {
      current_principal = {
        object_id = data.azurerm_client_config.current.object_id
        certificate_permissions = [
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
        ]

        key_permissions = [
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
        ]

        secret_permissions = [
          "Backup",
          "Delete",
          "Get",
          "List",
          "Purge",
          "Recover",
          "Restore",
          "Set"
        ]
      }
    }
  }

  key_vault_access_policies = (var.key_vault.access_model == "policy" ? merge(var.key_vault.access_policies, local.key_vault.implicit_access_policies) : {})
  key_vault_rbac_roles      = (var.key_vault.access_model == "rbac" ? merge(var.key_vault.rbac_roles, local.key_vault.implicit_rbac_roles) : {})

  datalake = {
    implicit_rbac_roles = {
      current_principal = {
        object_id            = data.azurerm_client_config.current.object_id
        role_definition_name = "Storage Blob Data Owner"
      }
    }
  }

  datalake_rbac_roles = (var.datalake.access_model == "rbac" ? merge(var.datalake.rbac_roles, local.datalake.implicit_rbac_roles) : {})

}
