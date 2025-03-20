terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"

    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }

    # azapi = {
    #   source = "Azure/azapi"
    # }

  }
  # backend "azurerm" {

  # }
}