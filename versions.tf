terraform {
  required_version = "~> 1.1"

  required_providers {
    time = {
      source  = "registry.terraform.io/hashicorp/time"
      version = "~> 0.7"
    }
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "~> 3.9"
    }
  }

}

