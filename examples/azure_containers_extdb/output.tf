output "AI_URL" {
  description = "URL for the AI service"
  value       = module.xmpro.AI_URL
}
output "AD_URL" {
  description = "URL for the AD service"
  value       = module.xmpro.AD_URL
}
output "DS_URL" {
  description = "URL for the DS service"
  value       = module.xmpro.DS_URL
}

output "SM_URL" {
  description = "URL for the SM service"
  value       = module.xmpro.SM_URL
}

output "sqlserver_fqdn" {
  description = "Fully Qualified Domain Name of the SQL Server"
  value       = module.xmpro.sqlserver_fqdn
}

output "CompanyName" {
  description = "Name of the company associated with this deployment"
  value       = module.xmpro.CompanyName
}
output "DSProductKey" {
  value = module.xmpro.DSProductKey
}

output "ADProductKey" {
  value = module.xmpro.ADProductKey
}
output "AIProductKey" {
  value = module.xmpro.AIProductKey
}

output "NBProductKey" {
  value = module.xmpro.NBProductKey

}

output "dns_zone_name" {
  value = module.xmpro.dns_zone_name
}

output "dns_zone_nameservers" {
  value = module.xmpro.dns_zone_nameservers
}

output "using_existing_sql_server" {
  description = "Indicates whether an existing SQL server is being used"
  value       = var.use_existing_sql_server
}

output "sql_server_url" {
  description = "URL of the SQL server (existing or newly created)"
  value       = var.existing_sql_server_url
}