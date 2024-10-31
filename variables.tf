variable "prefix" {
  description = "The prefix used for all resources in this example"
  default     = "xmdemo"
}
variable "environment" {
  description = "The prefix used for all resources in this example"
  default     = "jonahf"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default     = "australiaeast"
}

variable "imageversion" {
  description = "Docker image versions"
  default     = "latest"

}

variable "acr_url" {
  description = "Azure Container Registry Url"
  default     = "xmpro.azurecr.io"
}

variable "acr_url_product" {
  description = "Azure Container Registry Url"
  default     = "xmpro.azurecr.io"
}

variable "acr_username" {
  description = "Azure Container Registry Username"
  default     = "user"
}

variable "acr_password" {
  description = "Azure Container Registry Password"
  sensitive   = true
  default =  "none"
}

variable "docker_neo4j_auth" {
  default = "password1234"
}

variable "docker_rag_azure_openaichatdeploymentname" {
  description = "Azure chat deployment name to be used by the stream host"
  default     = "gpt4o"
}

variable "docker_rag_azure_openaiembeddingsdeploymentname" {
  description = "Azure embeddings deployment name by the stream host"
  default     = "text-embedding-ada-002"
}

variable "docker_rag_openaiversion" {
  description = "Azure openai version by the stream host"
  default     = "2024-02-01"
}
variable "db_admin_username" {
  description = "MSSQL username"
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

variable "companyname" {
  description = "SM Company Name"
  default     = "xmrrdev"

   validation {
    condition = length(var.companyname) <= 50
    error_message = "company name too long"
  }
}

variable "docker_rag_migration_script_path" {
  description = "value"
  default     = "/scripts"
}

variable "rabbitmq_user" {
  description = "RabbitMQ Username"
  default     = "rabbitmq"
}
variable "rabbitmq_password" {
  description = "RabbitMQ Password"
  default     = "rabbitpassword"
  sensitive   = true
}

# variable "docker_sh_mags_collection_id" {
#   sensitive = true
# }

# variable "docker_sh_mags_secret" {
#   sensitive = true
# }

variable "dns_zone_name" {
  description = "The DNS zone name"
  default     = "xmpro.com"
}

variable "first_name" {
  type    = string
  default = "xmpro"
}

variable "last_name" {
  type    = string
  default = "admin"
}

variable "email_address" {
  type    = string
  default = "xmpro.admin@onxmpro.com"
}

variable "sku_name" {
  type    = string
  default = "B2"
  validation {
    condition     = contains(["P1V2", "P2V2", "P3V2", "P1V3", "P2V3", "P3V3", "B2"], var.sku_name)
    error_message = "Must be a valid SKU name."
  }
}

variable "sku_capacity" {
  type    = number
  default = 1
  validation {
    condition     = var.sku_capacity >= 1 && var.sku_capacity <= 1
    error_message = "Must be 1."
  }
}

variable "database_dtus" {
  type    = number
  default = 10
  validation {
    condition     = var.database_dtus >= 10 && var.database_dtus <= 3000
    error_message = "Must be between 10 and 3000."
  }
}

variable "database_size" {
  type    = number
  default = 20
  validation {
    condition     = var.database_size >= 5 && var.database_size <= 1024
    error_message = "Must be between 5 and 1024 GB."
  }
}

variable "files_location" {
  type    = string
  default = "Files-4.4.10"
}

variable "enable_email_notification" {
  type    = bool
  default = true
}

variable "smtp_server" {
  type    = string
  default = "sinprd0310.outlook.com"
}

variable "smtp_from_address" {
  type    = string
  default = "sample@email.com"
}

variable "smtp_username" {
  type    = string
  default = "sample@email.com"
}

variable "smtp_password" {
  type    = string
  default = "newGuid()"
}

variable "smtp_port" {
  type    = number
  default = 25
}

variable "enable_ssl" {
  type    = bool
  default = true
}

variable "is_first_run" {
  type    = bool
  default = true
}

variable "is_azdo_pipeline" {
  type    = bool
  default = false
}
variable "sh_default_cpu" {
  type = number
  default = 1
}

variable "sh_default_memory" {
  type = number
  default = 4
}

variable "sh_ai_cpu" {
  type = number
  default = 1
}

variable "sh_ai_memory" {
  type = number
  default = 4
}

# --------------------------------------------------
# Existing SQL Server Configuration
# --------------------------------------------------

variable "use_existing_sql_server" {
  description = "Flag to determine whether to use an existing SQL server"
  type        = bool
  default     = false
}

variable "existing_sql_server_url" {
  description = "SQL Server FQDN + port (optional)"
  type = string
  default = ""
}

# --------------------------------------------------
# App name
# --------------------------------------------------

resource "random_string" "name_suffix" {
  length = 5
  special = false
  upper = false
  numeric = false
}