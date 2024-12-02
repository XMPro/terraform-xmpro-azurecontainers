variable "prefix" {
  description = "The prefix used for all resources in this example"
  default     = "xmpextdb"
}
variable "environment" {
  description = "The prefix used for all resources in this example"
  default     = "admindevops"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default     = "australiaeast"
}

variable "companyname" {
  description = "SM Company Name"
  default     = "dcomp1"
}

#----------------------
# db credentials
#----------------------

variable "db_admin_username" {
  description = "The username for the SQL Server administrator"
  sensitive   = true
  default     = "xmadmin"
}

variable "db_admin_password" {
  description = "The password for the SQL Server administrator"
  sensitive   = true
  default     = "2nUP5kb32pHq"
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

variable "is_first_run" {
  type    = bool
  default = false
}

variable "is_azdo_pipeline" {
  type    = bool
  default = false
}

#----------------------
# existing db variables
#----------------------

variable "use_existing_sql_server" {
  description = "Indicates whether an existing SQL server is being used"
  default     = true
}

variable "existing_sql_server_url" {
  description = "The fully qualified domain name of the Azure SQL Server (e.g., 'your-server-name.database.windows.net')"
  default     = "xmpro-devup-sqlserver.database.windows.net"
}