terraform {
  required_version = "1.1.9"

    required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.6.0"
    }
  }
  backend "azurerm" {  
    storage_account_name = "sastatedev"
    resource_group_name  = "rg-terraform-statefiles"
    container_name       = "tfstate"
    key                  = "token.tfstate"
  }
}

provider "azurerm" {
  features {}
}