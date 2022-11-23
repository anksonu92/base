resource "azurerm_key_vault" "lens" {
  //name                = format("%s-%s", var.key_vault.name, random_integer.suffix.result)
  name                =  var.key_vault.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enable_rbac_authorization   = var.key_vault.access_model == "rbac" ? true : false
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  sku_name                    = "standard"

  tags = var.tags

}

resource "azurerm_key_vault_access_policy" "lens" {
  for_each = local.key_vault_access_policies

  key_vault_id = azurerm_key_vault.lens.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = each.value.object_id

  certificate_permissions = each.value.certificate_permissions
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions

}

resource "azurerm_role_assignment" "lens_key_vault_rbac" {
  for_each = local.key_vault_rbac_roles

  scope                = azurerm_key_vault.lens.id
  principal_id         = each.value.object_id
  role_definition_name = each.value.role_definition_name
}

resource "time_sleep" "await_key_vault_rbac_propagation" {
  count = var.key_vault.access_model == "rbac" ? 1 : 0

  depends_on = [
    azurerm_role_assignment.lens_key_vault_rbac
  ]

  create_duration = var.rbac_propagation_await_time
}
