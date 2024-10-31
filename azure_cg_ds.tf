resource "azurerm_storage_share" "caddy_ds_data" {
  name                 = "share-ds-caddy-data"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 1
  depends_on           = [azurerm_storage_account.storage_account]
}

resource "azurerm_storage_share" "caddy_ds_config" {
  name                 = "share-ds-caddy-config"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 1
  depends_on           = [azurerm_storage_account.storage_account]
}

resource "azurerm_container_group" "ds" {
  name                = "cg-${var.prefix}-ds-${var.environment}-${var.location}"
  location            = azurerm_resource_group.xmprodocker.location
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ip_address_type     = "Public"
  dns_name_label      = "cg-${var.prefix}-ds-${var.environment}-${var.location}"
  os_type             = "Linux"

  image_registry_credential {
    server   = var.acr_url_product
    username = var.acr_username
    password = var.acr_password
  }

  container {
    name   = "ds"
    image  = "${var.acr_url_product}/ds:${var.imageversion}"
    cpu    = "0.5"
    memory = "2"

    environment_variables = {
      "ASPNETCORE_ENVIRONMENT"              = "dev"
      "ASPNETCORE_FORWARDEDHEADERS_ENABLED" = "true"
      "xm__Serilog__WriteTo__0__Name"       = "DatadogLogs"
      # "xm__Serilog__WriteTo__0__Args__apiKey"         = "${var.docker_ds_serilog_apikey}"
      "xm__ApplicationInsights__ConnectionString"     = "${azurerm_application_insights.appinsights.connection_string}"
      "xm__xmpro__xmsettings__adminRole"              = "Administrator"
      "xm__xmpro__xmsettings__data__connectionString" = "${local.ds_connection_string}"
      "xm__xmpro__data__connectionString"             = "${local.ds_connection_string}"
      "xm__xmpro__xmidentity__client__id"             = "${data.external.deployment_script_outputs.result["DSProductId"]}"
      "xm__xmpro__xmidentity__client__sharedkey"      = "${data.external.deployment_script_outputs.result["DSProductKey"]}"
      "xm__xmpro__xmidentity__client__baseUrl"        = "https://ds.${azurerm_dns_zone.dns.name}/"
      "xm__xmpro__xmidentity__server__baseUrl"        = "https://sm.${azurerm_dns_zone.dns.name}/"
      "xm__xmpro__keyVault__provider"                 = ""
      "xm__xmpro__keyVault__name"                     = ""
      "ASPNETCORE_URLS"                               = "http://+:5000"
      "xm__xmpro__featureFlags__enableAIAssistant"    = "true"
    }
    ports {
      port     = 5000
      protocol = "TCP"

    }

  }

  container {
    name   = "caddy"
    image  = "${var.acr_url}/caddy:latest"
    cpu    = "0.25"
    memory = "0.5"
    volume {
      name       = "data"
      mount_path = "/data"
      read_only  = false
      share_name = azurerm_storage_share.caddy_ds_data.name

      storage_account_name = azurerm_storage_account.storage_account.name
      storage_account_key  = azurerm_storage_account.storage_account.primary_access_key

    }

    volume {
      name       = "caddy-config"
      mount_path = "/config"
      read_only  = false
      share_name = azurerm_storage_share.caddy_ds_config.name

      storage_account_name = azurerm_storage_account.storage_account.name
      storage_account_key  = azurerm_storage_account.storage_account.primary_access_key

    }

    commands = [
      "caddy", "reverse-proxy", "--from", "ds.${azurerm_dns_zone.dns.name}", "--to", "http://cg-${var.prefix}-ds-${var.environment}-${var.location}.${var.location}.azurecontainer.io:5000"
    ]
    ports {
      port     = 443
      protocol = "TCP"
    }

  }

  exposed_port {
    port     = 443
    protocol = "TCP"
  }

  exposed_port {
    port     = 5000
    protocol = "TCP"
  }

  tags = {
    product    = "DS Caddy Reverse Proxy"
    createdby  = "jonahfrany"
    createdfor = "transition testing"
  }
}