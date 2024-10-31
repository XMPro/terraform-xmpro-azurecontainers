resource "azurerm_storage_share" "sh_data" {
  name                 = "share-data"
  storage_account_name = var.storage_account_name
  quota                = 10
  depends_on           = [var.storage_account_name]
}
