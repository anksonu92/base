resource "azurerm_user_assigned_identity" "cmk" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "customer-managed-key"
}
