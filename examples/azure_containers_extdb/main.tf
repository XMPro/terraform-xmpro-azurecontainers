resource "random_string" "dns_name" {
  length  = 5
  special = false
  upper   = false
}

module "xmpro" {
  source      = "../../"
  prefix      = var.prefix
  environment = var.environment
  location    = var.location
  companyname = var.companyname

  db_admin_username      = var.db_admin_username
  db_admin_password      = var.db_admin_password
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password

  dns_zone_name = "${var.environment}${random_string.dns_name.result}.xmpro.com"

  is_first_run     = false
  is_azdo_pipeline = true

  use_existing_sql_server = var.use_existing_sql_server
  existing_sql_server_url = var.existing_sql_server_url

}