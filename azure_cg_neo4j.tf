resource "azurerm_storage_share" "neo4j_data" {
  name                 = "share-neo4j-data"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 10
  depends_on           = [azurerm_storage_account.storage_account]
}

resource "azurerm_storage_share" "neo4j_import" {
  name                 = "share-neo4j-import"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 10
  depends_on           = [azurerm_storage_account.storage_account]
}

resource "azurerm_storage_share" "neo4j_conf" {
  name                 = "share-neo4j-conf"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 1
  depends_on           = [azurerm_storage_account.storage_account]
}

# resource "azurerm_storage_share" "neo4j_certs" {
#   name                 = "share-neo4j-certs"
#   storage_account_name = azurerm_storage_account.storage_account.name
#   quota                = 1
# }

resource "azurerm_storage_share" "caddy_neo4j_data" {
  name                 = "share-neo4j-caddy-data"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 1
  depends_on           = [azurerm_storage_account.storage_account]
}

resource "azurerm_storage_share" "caddy_neo4j_config" {
  name                 = "share-neo4j-caddy-config"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 1
  depends_on           = [azurerm_storage_account.storage_account]
}


resource "azurerm_container_group" "neo4j" {
  name                = "cg-${var.prefix}-neo4j-${var.environment}-${var.location}"
  location            = azurerm_resource_group.xmprodocker.location
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ip_address_type     = "Public"
  dns_name_label      = "cg-${var.prefix}-neo4j-${var.environment}-${var.location}"
  os_type             = "Linux"


  exposed_port {
    port     = 7474
    protocol = "TCP"
  }

  exposed_port {
    port     = 7473
    protocol = "TCP"
  }

  exposed_port {
    port     = 7687
    protocol = "TCP"
  }

  exposed_port {
    port     = 443
    protocol = "TCP"
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
      share_name = azurerm_storage_share.caddy_neo4j_data.name

      storage_account_name = azurerm_storage_account.storage_account.name
      storage_account_key  = azurerm_storage_account.storage_account.primary_access_key

    }

    # volume {
    #   name       = "caddy-config"
    #   mount_path = "/config"
    #   read_only  = false
    #   share_name = azurerm_storage_share.caddy_neo4j_config.name

    #   storage_account_name = azurerm_storage_account.storage_account.name
    #   storage_account_key  = azurerm_storage_account.storage_account.primary_access_key

    # }

    volume {
      name       = "config"
      mount_path = "/etc/caddy"
      read_only  = true
      secret = {
        "Caddyfile" = base64encode(<<-EOF
          {
            key_type rsa2048
          }
          neo4j.${azurerm_dns_zone.dns.name} {
            reverse_proxy cg-${var.prefix}-neo4j-${var.environment}-${var.location}.${var.location}.azurecontainer.io:7473
          }
          EOF
        ),
      }
    }
    # commands = [
    #   "caddy", "reverse-proxy", "--from", "neo4j.${azurerm_dns_zone.ykgw.name}", "--to",
    #   "cg-${var.prefix}-neo4j-${var.environment}-${var.location}.${var.location}.azurecontainer.io:7474",
    # ]
    ports {
      port     = 443
      protocol = "TCP"
    }

  }

  container {
    name   = "neo4j"
    image  = "${var.acr_url}/neo4j:latest"
    cpu    = "2"
    memory = "4"

    volume {
      name       = "neo4j-certs"
      mount_path = "/certificates"
      read_only  = true
      share_name = azurerm_storage_share.caddy_neo4j_data.name

      storage_account_name = azurerm_storage_account.storage_account.name
      storage_account_key  = azurerm_storage_account.storage_account.primary_access_key

    }
    volume {
      name       = "neo4j-data"
      mount_path = "/data"
      read_only  = false
      share_name = azurerm_storage_share.neo4j_data.name

      storage_account_name = azurerm_storage_account.storage_account.name
      storage_account_key  = azurerm_storage_account.storage_account.primary_access_key

    }

    volume {
      name       = "neo4j-import"
      mount_path = "/import"
      read_only  = false
      share_name = azurerm_storage_share.neo4j_import.name

      storage_account_name = azurerm_storage_account.storage_account.name
      storage_account_key  = azurerm_storage_account.storage_account.primary_access_key

    }
    volume {
      name       = "neo4j-conf"
      mount_path = "/conf"
      read_only  = false
      share_name = azurerm_storage_share.neo4j_conf.name

      storage_account_name = azurerm_storage_account.storage_account.name
      storage_account_key  = azurerm_storage_account.storage_account.primary_access_key

    }


    ports {
      port     = 7474
      protocol = "TCP"
    }

    ports {
      port     = 7473
      protocol = "TCP"
    }

    ports {
      port     = 7687
      protocol = "TCP"
    }

    environment_variables = {
      NEO4J_AUTH                                      = "neo4j/${var.docker_neo4j_auth}"
      NEO4J_ACCEPT_LICENSE_AGREEMENT                  = "yes"
      NEO4J_apoc_export_file_enabled                  = true
      NEO4J_apoc_import_file_enabled                  = true
      NEO4J_apoc_import_file_use__neo4j__config       = true
      NEO4J_PLUGINS                                   = "[\"apoc\"]"
      NEO4J_server_https_enabled                      = true
      NEO4J_dbms_ssl_policy_https_enabled             = true
      NEO4J_dbms_ssl_policy_https_private__key        = "neo4j.${azurerm_dns_zone.dns.name}.key"
      NEO4J_dbms_ssl_policy_https_public__certificate = "neo4j.${azurerm_dns_zone.dns.name}.crt"
      NEO4J_dbms_ssl_policy_https_base__directory     = "/certificates/caddy/certificates/acme-v02.api.letsencrypt.org-directory/neo4j.${azurerm_dns_zone.dns.name}"
      NEO4J_dbms_ssl_policy_bolt_enabled              = true
      NEO4J_dbms_ssl_policy_bolt_private__key         = "neo4j.${azurerm_dns_zone.dns.name}.key"
      NEO4J_dbms_ssl_policy_bolt_public__certificate  = "neo4j.${azurerm_dns_zone.dns.name}.crt"
      NEO4J_dbms_ssl_policy_bolt_base__directory      = "/certificates/caddy/certificates/acme-v02.api.letsencrypt.org-directory/neo4j.${azurerm_dns_zone.dns.name}"
      NEO4J_dbms_ssl_policy_bolt_client__auth         = "NONE"
      NEO4J_server_bolt_tls__level                    = "REQUIRED"
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.logs.workspace_id
      log_type      = "ContainerInsights"
      workspace_key = azurerm_log_analytics_workspace.logs.primary_shared_key
    }

  }
  tags = {
    product    = "Neo4j Database"
    createdby  = "jonahfrany"
    createdfor = "transition testing"
    datadog    = "true"
  }
}

