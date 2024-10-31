

locals {
    mssql_server_url      = var.use_existing_sql_server ? var.existing_sql_server_url : azurerm_mssql_server.mssql[0].fully_qualified_domain_name
    mssql_admin_login     = var.use_existing_sql_server ? var.db_admin_username : azurerm_mssql_server.mssql[0].administrator_login
    mssql_admin_password  = var.use_existing_sql_server ? var.db_admin_password : azurerm_mssql_server.mssql[0].administrator_login_password
}

locals {
    base_connection_string = "Server=tcp:${local.mssql_server_url};persist security info=True;user id=${local.mssql_admin_login};password=${local.mssql_admin_password};"

    ad_connection_string = "${local.base_connection_string}Initial Catalog=AD;"
    ds_connection_string = "${local.base_connection_string}Initial Catalog=DS;"
    ai_connection_string = "${local.base_connection_string}Initial Catalog=AI;"
}