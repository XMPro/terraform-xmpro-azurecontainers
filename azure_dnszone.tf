resource "random_string" "dns_name" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_dns_zone" "dns" {
  #name                = "${var.environment}${random_string.dns_name.result}.xmpro.com"
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.xmprodocker.name
}

resource "azurerm_dns_a_record" "something" {
  name                = "something1"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ttl                 = 300
  records             = ["8.8.8.8"]
}

resource "azurerm_dns_cname_record" "ai" {
  name                = "ai"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ttl                 = 300
  record              = azurerm_container_group.ai.fqdn
}

resource "azurerm_dns_cname_record" "ds" {
  name                = "ds"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ttl                 = 300
  record              = azurerm_container_group.ds.fqdn
}

resource "azurerm_dns_cname_record" "ad" {
  name                = "ad"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ttl                 = 300
  record              = azurerm_container_group.ad.fqdn
}


resource "azurerm_dns_cname_record" "rabbitmq" {
  name                = "rabbitmq"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ttl                 = 300
  record              = azurerm_container_group.rabbitmq.fqdn
}
resource "azurerm_dns_cname_record" "neo4j" {
  name                = "neo4j"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.xmprodocker.name
  ttl                 = 300
  record              = azurerm_container_group.neo4j.fqdn
}

