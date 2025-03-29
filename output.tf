output "ai_url" {
  value = trim(azurerm_dns_cname_record.ai.fqdn, ".")
}
output "ad_url" {
  value = trim(azurerm_dns_cname_record.ad.fqdn, ".")
}
output "ds_url" {
  value = trim(azurerm_dns_cname_record.ds.fqdn, ".")
}
output "sm_url" {
  value = module.sm.dns_cname_record_fqdn
}

output "sqlserver_fqdn" {
  value = var.use_existing_sql_server ? var.existing_sql_server_url : azurerm_mssql_server.mssql[0].fully_qualified_domain_name
}

output "CompanyName" {
  value = var.companyname
}
output "DSProductKey" {
  value = module.sm.DSProductKey #data.external.deployment_script_outputs.result["DSProductKey"]
}

output "ADProductKey" {
  value = module.sm.ADProductKey #data.external.deployment_script_outputs.result["ADProductKey"]
}

output "AIProductKey" {
  value = module.sm.AIProductKey #data.external.deployment_script_outputs.result["AIProductKey"]
}

output "NBProductKey" {
  value = module.sm.NBProductKey #data.external.deployment_script_outputs.result["NBProductKey"]
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

output "resource_group_location" {
  value = azurerm_resource_group.xmprodocker.location
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name

}

output "storage_account_primary_access_key" {
  value = azurerm_storage_account.storage_account.primary_access_key

}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.logs.workspace_id
}

output "log_analytics_primary_shared_key" {
  value = azurerm_log_analytics_workspace.logs.primary_shared_key
}

output "appinsights_connectionstring" {
  value = azurerm_application_insights.appinsights.connection_string
}

output "data_client_config" {
  value = data.azurerm_client_config.current.tenant_id
}