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

variable "docker_azure_openaichatdeploymentname" {
  description = "Azure chat deployment name to be used by the stream host"
  default     = "gpt4o"
}

variable "docker_azure_openaiembeddingsdeploymentname" {
  description = "Azure embeddings deployment name by the stream host"
  default     = "text-embedding-ada-002"
}

variable "docker_openaiversion" {
  description = "Azure openai version by the stream host"
  default     = "2024-02-01"
}

variable "docker_migration_script_path" {
  description = "value"
  default     = "/scripts"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "storage_account_primary_access_key" {
  description = "The storage account primary access key"
  type        = string
}

variable "streamhost_container_image" {
  description = "The docker container image to be used by the stream host"
  default     = "xmprocontrib.azurecr.io/sh-debian-ai-assistant:latest"
}

variable log_analytics_id {
  description = "This variable holds the ID of the Log Analytics workspace"
  type = string
}

variable log_analytics_primary_shared_key {
  description = "This variable holds the primary shared key for the Log Analytics workspace"
  type = string
}

variable "container_streamhost_data" {
  
}