# XMPro - Azure Containers Terraform Module

## Overview
This Terraform module facilitates the deployment of XMPRo resources on Azure using Terraform CLI commands. It is designed for a fresh installation of all XMPRo products, including the necessary infrastructure and configurations. The module allows you to customize various parameters such as resource names, environment settings, and resource allocations to suit your specific deployment needs. By using this module, you can ensure a consistent and repeatable setup process for XMPRo products in your Azure environment.

## Prerequisites

### Required Tools

| Tool                      | Version | Purpose                 | Installation Link                                                                                         |
|------                     |---------|---------                |-------------------                                                                                        |
| Terraform CLI             | >= 1.0  | Infrastructure as Code  | [Install Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)          |
| Docker Desktop            | Latest  | Containerization        | [Download](https://www.docker.com/products/docker-desktop/)                                               |
| Azure CLI                 | Latest  | Azure Management        | [Install Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)     |
| Azure Portal Access       | N/A     | Cloud Management        | [Portal](https://portal.azure.com/)                                                                       |
| PowerShell/Ubuntu Bash    | Latest  | Command Line Interface  | [Ubuntu](https://www.microsoft.com/store/productId/9PN20MSR04DW)                                          |    
| XMPro Git Repository      | Latest  | Source Code             | [Repository](https://xmpro.visualstudio.com/DefaultCollection/XMPro%20Development/_git/xmpro-development) |
| VS Code (Optional)        | Latest  | IDE                     | [Download](https://code.visualstudio.com/)                                                                |

## Quick Start Guide

### 1. Environment Setup

1. **Start Docker**
   - Ensure Docker is installed and running on your machine.

2. **Configure Azure Environment**
   Create `az.env` file with your Azure credentials:
   ```env
   ARM_TENANT_ID=<your-tenant-id>
   ARM_SUBSCRIPTION_ID=<your-subscription-id>
   ```

3. **Get Azure Credentials**
   ```bash
   # Login to Azure
   az login

   # List accounts and get Tenant/Subscription IDs
   az account list -o table
   ```

### 2. Deployment Steps

1. **Create your main module and copy paste into your terraform directory**

   ```
      module "<block_name>" {
         source  = "XMPro/azurecontainers/xmpro"
         version = "0.0.5"
         # insert the required variables here
      }
   ```

2. **Run Docker Container**
   ```bash
   docker run -it --rm \
      --env-file az.env \
      -v <path-to-git-repo>:/opt/terraform \
     xmpro.azurecr.io/xmterraform
   ```
   Example `<path-to-git-repo>` : `F:\projects\xmpro`
   <br>
   *The folder path should will contain the az.env file as well*

3. **Navigate Inside Container**
   ```bash
   cd <path-of-your-terraform-directory>
   ```

## Configuration

### Key Variables

Update the following variables in `main.tf` according to your requirements:

| Variable                      | Description               | Example                       |
|----------                     |-------------              |----------                     |
| `prefix`                      | Resource prefix           | `xmpro`                       |
| `environment`                 | Deployment environment    | `dev`, `prod`                 |
| `location`                    | Azure region              | `eastus`                      |
| `companyname`                 | Company name in database  | `MyCompany`                   |
| `db_admin_username`           | Database username         | `admin`                       |
| `db_admin_password`           | Database password         | `<use-secure-password>`       |
| `company_admin_password`      | Database password         | `<use-secure-password>`       |
| `site_admin_password`         | Database password         | `<use-secure-password>`       |
| `dns_zone_name`               | DNS zone for webapp       | `example.com`                 |
| `using_existing_sql_server`   | Use existing database     | `true`                        |
| `existing_sql_server_url`     | SQL Server URL            | `server.database.windows.net` |

## Terraform Commands

| Command              | Description                  | When to Use      |
|---------             |-------------                 |-------------     |
| `terraform init`     | Initialize working directory | First time setup |
| `terraform apply`    | Apply changes                | To deploy        |
| `terraform destroy`  | Remove resources             | To clean up      |

<br>
> ⚠️ **Warning**: Always run `terraform destroy` when you need to remove deployed resources to avoid unnecessary charges.


<br><br>
**Note:** Keep this documentation updated as the module evolves. Last updated: 2024