resource "azurerm_storage_account" "lens_datalake" {
  name                = var.datalake.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_kind             = "StorageV2"
  account_tier             = var.datalake.tier
  account_replication_type = var.datalake.replication_type

  is_hns_enabled = true

  enable_https_traffic_only = true
  shared_access_key_enabled = var.datalake.access_model == "sas" ? true : false
  min_tls_version           = "TLS1_2"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cmk.id]
  }

  blob_properties {
    last_access_time_enabled = true

    container_delete_retention_policy {
      days = var.datalake.data_retention_in_days
    }

    delete_retention_policy {
      days = var.datalake.data_retention_in_days
    }

  }

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.lens_datalake.id
    user_assigned_identity_id = azurerm_user_assigned_identity.cmk.id
  }

  tags = var.tags
}

resource "azurerm_storage_account_network_rules" "lens_datalake" {
  storage_account_id = azurerm_storage_account.lens_datalake.id

  default_action = "Allow"

  bypass = [
    "Metrics",
    "Logging",
    "AzureServices"
  ]
}

resource "azurerm_key_vault_key" "lens_datalake" {
  //name         = format("%s%s-%s", var.datalake.name, random_integer.suffix.result, "enc-key")
  name         = var.datalake.name
  key_vault_id = azurerm_key_vault.lens.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    time_sleep.await_key_vault_rbac_propagation
  ]
}

resource "azurerm_role_assignment" "datalake_principal_to_encryption_key_vault" {
  scope                = azurerm_key_vault.lens.id
  principal_id         = azurerm_user_assigned_identity.cmk.principal_id
  role_definition_name = "Key Vault Crypto Service Encryption User" #note: this role includes wrapKey (not needed for CMK storage encryption, but no built-in role exists)
}

resource "azurerm_role_assignment" "lens_datalake" {
  for_each = local.datalake_rbac_roles

  scope                = azurerm_storage_account.lens_datalake.id
  principal_id         = each.value.object_id
  role_definition_name = each.value.role_definition_name
}

resource "time_sleep" "await_datalake_rbac_propagation" {
  depends_on = [
    azurerm_role_assignment.lens_datalake,
    azurerm_role_assignment.datalake_principal_to_encryption_key_vault
  ]

  create_duration = var.rbac_propagation_await_time
}

resource "azurerm_storage_data_lake_gen2_filesystem" "lens_datalake" {
  for_each = toset(var.datalake.containers)

  name               = each.value
  storage_account_id = azurerm_storage_account.lens_datalake.id

  depends_on = [
    time_sleep.await_datalake_rbac_propagation
  ]
}
