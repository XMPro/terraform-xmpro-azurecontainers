data "azurerm_client_config" "current" {}

module "sm" {
    source = "../terraform-xmpro-sm"

    prefix = var.prefix
    environment = var.environment
    location = var.location
    files_location = var.files_location

    use_existing_sql_server = var.use_existing_sql_server_for_sm
    existing_sql_server_url = local.mssql_server_url
    existing_sql_server_resource_group = azurerm_resource_group.xmprodocker.name
    is_new_installation = var.is_new_installation_for_sm

    use_existing_dns_zone = var.use_existing_dns_zone_for_sm
    existing_dns_zone_name = azurerm_dns_zone.dns.name
    existing_dns_zone_nameservers = azurerm_dns_zone.dns.name_servers

    use_existing_client_config = var.use_existing_client_config
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
}