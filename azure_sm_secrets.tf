resource "azurerm_key_vault_secret" "sqlserver" {
  name         = "SQLSERVER"
  value        = format("Data Source=tcp:%s,1433;Initial Catalog=SM;User ID=%s;Password=%s;", local.mssql_server_url, local.mssql_admin_login, local.mssql_admin_password)
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

locals {
  sm_command = join(" ", ["pwsh", "${path.module}/TerraformSM.ps1",
    "-targetServerName", "${local.mssql_server_url}",
    "-targetUser", "${local.mssql_admin_login}",
    "-targetPassword", "${local.mssql_admin_password}",
    "-smDbMigrationsExeUri", "https://xmmarketplacestorage.blob.core.windows.net/deploymentpackage/${var.files_location}/XMIdentity.Database.Console",
    "-DSUrl", "https://ds.${azurerm_dns_zone.dns.name}",
    "-ADUrl", "https://ad.${azurerm_dns_zone.dns.name}",
    "-AIUrl", "https://ai.${azurerm_dns_zone.dns.name}",
    "-NBUrl", "https://nb.${azurerm_dns_zone.dns.name}/hub/oauth_callback",
    "-CompanyName", "${var.companyname}",
    "-FirstName", "${var.first_name}",
    "-LastName", "${var.last_name}",
    "-UserName", "xmpro.admin@${var.companyname}.onxmpro.com",
    "-Email", "${var.email_address}",
    "-CompanyAdminPassword", "${var.company_admin_password}",
    "-SiteAdminPassword", "${var.site_admin_password}",
    "-EnableAi", "true"
  ])
}

resource "null_resource" "run_script" {
  count      = var.use_existing_sql_server ? 0 : 1
  depends_on = [azurerm_mssql_database.sm, azurerm_mssql_firewall_rule.allow_local_access]
  triggers = {
    script_hash = filebase64sha256("${path.module}/TerraformSM.ps1")
    condition   = var.is_first_run == true
  }

  provisioner "local-exec" {
    command = local.sm_command
  }
}

data "external" "deployment_script_outputs" {
  program = ["pwsh", "${path.module}/TerraformSMoutputs.ps1",
    "-targetServerName", "${local.mssql_server_url}",
    "-targetUser", var.db_admin_username,
  "-targetPassword", var.db_admin_password]
  depends_on = [null_resource.run_script, azurerm_mssql_database.sm, azurerm_mssql_firewall_rule.allow_local_access]
}

resource "azurerm_key_vault_secret" "productid" {
  name         = "ServerUUID"
  value        = data.external.deployment_script_outputs.result["SMProductId"]
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "dns" {
  name         = "DNSName"
  value        = "https://sm.${azurerm_dns_zone.dns.name}"
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "cert" {
  name         = "CERT"
  value        = "CN=${var.companyname}-SM-Sign-${random_uuid.cert_sign.result}"
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "random_string" "salt" {
  length  = 13
  special = false
}

resource "azurerm_key_vault_secret" "salt" {
  name         = "SALT"
  value        = random_string.salt.result
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "autoscale" {
  name         = "AutoScaleEnable"
  value        = "false"
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "redis" {
  name         = "REDIS"
  value        = "-"
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "smtp_enable" {
  name         = "SMTPENABLE"
  value        = var.enable_email_notification
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "smtp_server" {
  name         = "SMTPSERVER"
  value        = var.smtp_server
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "smtp_from" {
  name         = "SMTPFrom"
  value        = var.smtp_from_address
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "smtp_user" {
  name         = "SMTPUSER"
  value        = var.smtp_username
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "smtp_password" {
  name         = "SMTPPASS"
  value        = var.smtp_password
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "smtp_port" {
  name         = "SMTPPORT"
  value        = var.smtp_port
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

resource "azurerm_key_vault_secret" "enable_ssl" {
  name         = "SMTPENABLESSL"
  value        = var.enable_ssl
  key_vault_id = azurerm_key_vault.sm_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}