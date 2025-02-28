resource "azurerm_storage_share" "caddy_ai_data" {
  name                 = "share-ai-caddy-data"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 1
  depends_on           = [azurerm_storage_account.storage_account]
}

resource "azurerm_storage_share" "caddy_ai_config" {
  name                 = "share-ai-caddy-config"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 1
  depends_on           = [azurerm_storage_account.storage_account]
}

resource "azurerm_container_group" "ai" {
  name                = "cg-${var.prefix}-ai-${var.environment}-${var.location}"
  location            = azurerm_resource_group.xmprodocker.location
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ip_address_type     = "Public"
  dns_name_label      = "cg-${var.prefix}-ai-${var.environment}-${var.location}"
  os_type             = "Linux"
  depends_on          = [ azurerm_key_vault.ai_vault ]

  image_registry_credential {
    server   = var.acr_url_product
    username = var.acr_username
    password = var.acr_password
  }

  identity {
    type = "SystemAssigned"
  }

  container {
    name   = "ai"
    image  = "${var.acr_url_product}/ai:${var.imageversion}"
    cpu    = "0.5"
    memory = "1.5"

    environment_variables = {
      "ASPNETCORE_ENVIRONMENT"                                                = "dev"
      "ASPNETCORE_FORWARDEDHEADERS_ENABLED"                                   = "true"
      "ASPNETCORE_URLS"                                                       = "http://+:5000"
      "xm__xmpro__keyVault__provider"                                         = "Azure"
      "xm__xmpro__keyVault__name"                                             = azurerm_key_vault.ai_vault.name
      "xm__xmpro__xmsettings__adminRole"                                      = "Administrator"
      "xm__xmpro__xmidentity__client__baseUrl"                                = "https://ai.${azurerm_dns_zone.dns.name}/"
      "xm__xmpro__xmidentity__server__baseUrl"                                = "https://sm.${azurerm_dns_zone.dns.name}/"
      "xm__xmpro__aIDesigner__jupyterUrl__url"                                = "https://xmpro-jupyter-dev.southeastasia.cloudapp.azure.com"
      "xm__xmpro__aIDesigner__aiAssistant__mqtt__broker"                      = "rabbitmq.${azurerm_dns_zone.dns.name}"
      "xm__xmpro__aIDesigner__aiAssistant__mqtt__port"                        = "1883"
      "xm__xmpro__aIDesigner__aiAssistant__mqtt__clientid"                    = "aiserver"
      "xm__xmpro__aIDesigner__aiAssistant__mqtt__statusTopic"                 = "v1/xmpro/ai/aiassistant/conversation/datastream/aiserver/status"
      "xm__xmpro__aIDesigner__aiAssistant__mqtt__timeoutDuration"             = "250"
      "xm__xmpro__aIDesigner__featureFlags__enableAIAssistant"                = "true"
      "xm__xmpro__healthChecks__cssPath"                                      = "/app/ClientApp/dist/en-US/assets/content/styles/healthui.css"
      "xm__xmpro__gateway__featureflags__enableapplicationinsightstelemetry"  = true
      "xm__applicationinsights__minimumlevel__default"                        = var.appinsights_minimum_level_default
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
      share_name = azurerm_storage_share.caddy_ai_data.name

      storage_account_name = azurerm_storage_account.storage_account.name
      storage_account_key  = azurerm_storage_account.storage_account.primary_access_key

    }

    volume {
      name       = "caddy-config"
      mount_path = "/config"
      read_only  = false
      share_name = azurerm_storage_share.caddy_ai_config.name

      storage_account_name = azurerm_storage_account.storage_account.name
      storage_account_key  = azurerm_storage_account.storage_account.primary_access_key

    }

    commands = [
      "caddy", "reverse-proxy", "--from", "ai.${azurerm_dns_zone.dns.name}", "--to", "http://cg-${var.prefix}-ai-${var.environment}-${var.location}.${var.location}.azurecontainer.io:5000"
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

  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.logs.workspace_id
      log_type      = "ContainerInsights"
      workspace_key = azurerm_log_analytics_workspace.logs.primary_shared_key
    }
  }

  tags = {
    product    = "AI Caddy Reverse Proxy"
    createdby  = "jonahfrany"
    createdfor = "transition testing"
  }
}