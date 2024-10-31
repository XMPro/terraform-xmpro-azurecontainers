## PLACEHOLDER for Dev docker streamhosts

resource "random_uuid" "sh_id" {
  for_each = { for key, value in var.container_streamhost_data : key => value }
}

resource "azurerm_container_group" "streamhost" {
  for_each = { for key, value in var.container_streamhost_data : key => value }
  name                = "cg-${var.prefix}-${each.value.name}-${var.environment}-${var.location}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  dns_name_label      = "cg-${var.prefix}-${each.value.name}-${var.environment}-${var.location}"
  os_type             = "Linux"

  container {
    name = "sh"
    image  = var.streamhost_container_image
    cpu    = each.value.sh_cpu
    memory = each.value.sh_memory

    environment_variables = {
      "xm__xmpro__Gateway__Id"                    = "${random_uuid.sh_id[each.key].result}"
      "xm__xmpro__Gateway__Name"                  = format("SH-%02d-%s-ACI-%s", index(keys(var.container_streamhost_data), each.key) + 1, each.value.name, var.environment)
      "xm__xmpro__Gateway__ServerUrl"             = each.value.gateway_server_url
      "xm__xmpro__Gateway__CollectionId"          = each.value.gateway_collection_id
      "xm__xmpro__Gateway__Secret"                = each.value.gateway_secret
      "xm__ApplicationInsights__ConnectionString" = each.value.appinsights_connectionstring
      "AZURE_OPENAI_CHAT_DEPLOYMENT_NAME"       = "${var.docker_azure_openaichatdeploymentname}"
      "AZURE_OPENAI_EMBEDDINGS_DEPLOYMENT_NAME" = "${var.docker_azure_openaiembeddingsdeploymentname}"
      "OPENAI_API_VERSION"                      = "${var.docker_openaiversion}"
      "SCRIPT_PATH" = "${var.docker_migration_script_path}"
    }

    volume {
      name       = "rag-data"
      mount_path = "/scripts"
      read_only  = false
      share_name = azurerm_storage_share.sh_data.name

      storage_account_name = var.storage_account_name
      storage_account_key  = var.storage_account_primary_access_key

    }

    ports {
      port     = 5000
      protocol = "TCP"

    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = var.log_analytics_id
      workspace_key = var.log_analytics_primary_shared_key
      log_type      = "ContainerInsights"
    }
  }

  tags = {
    product    = "XMPRO-${each.value.name}"
    createdby  = "admin-${each.value.name}"
    createdfor = "${var.prefix}-${var.environment}-docker"
  }
}