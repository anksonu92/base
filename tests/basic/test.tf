terraform {
  required_version = "~> 1.1"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "~> 3.9"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3.0"
    }
    time = {
      source  = "registry.terraform.io/hashicorp/time"
      version = "~> 0.7"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = false
  storage_use_azuread        = true # prereq to using 'rbac' access model!
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  location = "eastus2"
  name     = "lens-base-test-basic"
}

module "lens_base" {
  source = "../../"

  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  depends_on = [
    azurerm_resource_group.test
  ]
}

output "key_vault" {
  value = module.lens_base.key_vault
}

output "datalake" {
  value = module.lens_base.datalake
}
