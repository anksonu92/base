output "key_vault" {
  description = "Key Vault resource"
  value = {
    id        = azurerm_key_vault.lens.id
    name      = azurerm_key_vault.lens.name
    location  = azurerm_key_vault.lens.location
    vault_uri = azurerm_key_vault.lens.vault_uri
  }
}

output "datalake" {
  description = "Datalake resource"
  value = {
    id                    = azurerm_storage_account.lens_datalake.id
    name                  = azurerm_storage_account.lens_datalake.name
    location              = azurerm_storage_account.lens_datalake.location
    primary_dfs_endpoint  = azurerm_storage_account.lens_datalake.primary_dfs_endpoint
    primary_blob_endpoint = azurerm_storage_account.lens_datalake.primary_blob_endpoint
    containers = { for container in azurerm_storage_data_lake_gen2_filesystem.lens_datalake : container.name => {
      name = container.name
      id   = container.id
      }
    }
  }
}
