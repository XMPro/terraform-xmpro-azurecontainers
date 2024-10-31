provider "azurerm" {
  features {
    # key_vault {
    #   recover_soft_deleted_key_vaults = false
    # }
  }
}

resource "azurerm_resource_group" "xmprodocker" {
  name     = "rg-${var.prefix}-${var.environment}-${var.location}"
  location = var.location
  tags = {
    Created_For    = "XMPRO ${var.environment} docker sites"
    Created_By     = "jonahfrany"
    Keep_or_delete = "Keep"

  }
}

