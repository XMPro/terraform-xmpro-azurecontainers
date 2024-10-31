resource "azurerm_service_plan" "app_service_plan" {
  name                = format("%s-Plan", var.companyname)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Windows"
  sku_name            = var.sku_name
}

data "azurerm_key_vault_secret" "sm_cert" {
  name         = "generated-cert"
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on   = [azurerm_key_vault_certificate.cert, azurerm_key_vault_access_policy.terraform, azurerm_key_vault_access_policy.ms_webapp]
}

resource "azurerm_app_service_certificate" "sm_signing_cert" {
  name                = "SM-SigningCert"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  app_service_plan_id = azurerm_service_plan.app_service_plan.id
  pfx_blob            = data.azurerm_key_vault_secret.sm_cert.value
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "sm_vault" {
  name                = format("%s-vault-%s", var.companyname, random_string.name_suffix.result)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.sm_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "SetIssuers",
    "Update",
  ]

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]
}

resource "azurerm_key_vault_access_policy" "ms_webapp" {
  key_vault_id = azurerm_key_vault.sm_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_web_app.sm_website.identity[0].principal_id

  certificate_permissions = [
    "Get",
    "Update",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]
}
resource "random_uuid" "cert_sign" {
}
resource "azurerm_key_vault_certificate" "cert" {
  name         = "generated-cert"
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on   = [azurerm_key_vault_access_policy.terraform]

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      # subject_alternative_names {
      #   dns_names = ["internal.contoso.com", "domain.hello.world1111"]
      # }

      subject            = "CN=${var.companyname}-SM-Sign-${random_uuid.cert_sign.result}"
      validity_in_months = 60
    }
  }
}

# resource "null_resource" "download_SM" {
#   triggers = {
#     always_run = timestamp()
#   }

#   provisioner "local-exec" {
#     command = "wget -O SM.zip https://xmmarketplacestorage.blob.core.windows.net/deploymentpackage/${var.files_location}/SM.zip"
#   }
# }

resource "azurerm_windows_web_app" "sm_website" {
  name                = format("%s-SM-%s", var.companyname, random_string.name_suffix.result)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id


  site_config {
    websockets_enabled = true
    use_32_bit_worker  = false
    http2_enabled      = true
  }

  # zip_deploy_file = "./SM.zip"
  app_settings = {
    "WEBSITE_LOAD_CERTIFICATES"    = "*"
    "MSDEPLOY_RENAME_LOCKED_FILES" = "1"
  }

  identity {
    type = "SystemAssigned"
  }

  https_only = true

  depends_on = [
    azurerm_mssql_database.sm,
    azurerm_mssql_server.mssql[0],
    azurerm_service_plan.app_service_plan,
  ]
}


resource "azurerm_resource_group_template_deployment" "MSDeploy" {
  name                = "MSDeploy"
  resource_group_name = azurerm_resource_group.main.name
  deployment_mode     = "Incremental"

  parameters_content = jsonencode({
    "smWebsiteName" = {
      value = "${azurerm_windows_web_app.sm_website.name}"
    },
    "smZipLocation" = {
      value = "https://xmmarketplacestorage.blob.core.windows.net/deploymentpackage/${var.files_location}/SM.zip"
    },
    "smWebsiteVaultName" = {
      value = "${azurerm_key_vault.sm_vault.name}"
    },

  })

  template_content = file("${path.module}/site_extensions.json")
  depends_on       = [azurerm_windows_web_app.sm_website]
}

resource "azurerm_dns_txt_record" "domain_verification" {
  name                = "asuid"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ttl                 = 300

  record {
    value = azurerm_windows_web_app.sm_website.custom_domain_verification_id
  }
}

resource "azurerm_dns_cname_record" "sm" {
  name                = "sm"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ttl                 = 300
  record              = azurerm_windows_web_app.sm_website.default_hostname

  depends_on = [azurerm_dns_txt_record.domain_verification]
}

resource "azurerm_app_service_custom_hostname_binding" "hostname_binding" {
  hostname            = "sm.${azurerm_dns_zone.dns.name}"
  app_service_name    = azurerm_windows_web_app.sm_website.name
  resource_group_name = azurerm_resource_group.main.name

  depends_on = [azurerm_dns_cname_record.sm]
}

resource "azurerm_app_service_managed_certificate" "sm_cert" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.hostname_binding.id
}

resource "azurerm_app_service_certificate_binding" "sm_cert" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.hostname_binding.id
  certificate_id      = azurerm_app_service_managed_certificate.sm_cert.id
  ssl_state           = "SniEnabled"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-SM-${var.companyname}-${var.environment}-${var.location}"
  location = var.location
  tags = {
    Created_For    = "XMPRO SM ${var.environment} docker site"
    Created_By     = "jonahfrany"
    Keep_or_delete = "Keep"

  }
}

output "sql_server_name" {
  value = var.use_existing_sql_server ? null : azurerm_mssql_server.mssql[0].name
}
