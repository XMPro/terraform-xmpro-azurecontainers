output "AI_URL" {
  value = azurerm_dns_cname_record.ai.fqdn
}
output "AD_URL" {
  value = azurerm_dns_cname_record.ad.fqdn
}
output "DS_URL" {
  value = azurerm_dns_cname_record.ds.fqdn
}

output "SM_URL" {
  value = azurerm_dns_cname_record.sm.fqdn
}

output "sqlserver_fqdn" {
  value = var.use_existing_sql_server ? var.existing_sql_server_url : azurerm_mssql_server.mssql[0].fully_qualified_domain_name
}

output "CompanyName" {
  value = var.companyname
}
output "DSProductKey" {
  value = data.external.deployment_script_outputs.result["DSProductKey"]
}

output "ADProductKey" {
  value = data.external.deployment_script_outputs.result["ADProductKey"]
}

output "AIProductKey" {
  value = data.external.deployment_script_outputs.result["AIProductKey"]
}

output "NBProductKey" {
  value = data.external.deployment_script_outputs.result["NBProductKey"]
}

# output "DefaultId" {
#   value = data.external.ds_sh_outputs.result["DefaultId"]
# }

# output "DefaultSecret" {
#   value = data.external.ds_sh_outputs.result["DefaultSecret"]
# }

# output "AIAssistantId" {
#   value = data.external.ds_sh_outputs.result["AIAssistantId"]
# }

# output "AIAssistantSecret" {
#   value = data.external.ds_sh_outputs.result["AIAssistantSecret"]
# }

output "dns_zone_name" {
  value = azurerm_dns_zone.dns.name
}

output "dns_zone_nameservers" {
  value = azurerm_dns_zone.dns.name_servers
}

output "resource_group_name" {
  value = azurerm_resource_group.xmprodocker.name
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
  
}

output "storage_account_primary_access_key" {
  value = azurerm_storage_account.storage_account.primary_access_key
  
}