variable "prefix" {
  description = "The prefix used for all resources in this example"
  default     = "xmpro"
}

variable "environment" {
  description = "The environment name used for all resources in this example"
  default     = "demo"
}

variable "location" {
  description = "The location where the resources will be deployed"
  default     = "southeastasia"
}

variable "companyname" {
  description = "The company name used for all resources in this example"
  default     = "xmdemo"
}

variable "db_admin_username" {
  description = "MSSQL username"
  sensitive   = true
  default     = "xmadmin"
}

variable "db_admin_password" {
  description = "MSSQL password"
  sensitive   = true
  default     = "Password1234!"
}

variable "company_admin_password" {
  description = "SM Comapny Admin password"
  sensitive   = true
  default     = "Password1234!"
}

variable "site_admin_password" {
  description = "SM site admin password"
  sensitive   = true
  default     = "Password1234!"
}

variable "dns_zone_name" {
  description = "The DNS zone name"
  default     = "nonprod.xmprodev.com"
}