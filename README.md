# XMPro - Azure Containers Terraform Module

## Overview
This Terraform module helps you deploy resources on Azure using Terraform CLI commands. It allows you to customize variables for resource names, environment settings, and resource allocations. This module is designed for a fresh installation of all XMPRo resources.

> 💡 **Tip**: Press `Ctrl + Shift + V` in VS Code to preview this Markdown file.

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

1. **Navigate to Module Directory**
   ```bash
   cd /path/to/xmpro-development/deploy/terraform/examples/azure_containers_extdb
   ```

2. **Run Docker Container**
   ```bash
   docker run -it --rm \
     -v <path-to-git-repo>:/opt/terraform \
     xmpro.azurecr.io/xmterraform
   ```

3. **Navigate Inside Container**
   ```bash
   cd deploy/terraform/examples/azure_containers_extdb
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
| `docker_db_admin_username`    | Database username         | `admin`                       |
| `docker_db_admin_password`    | Database password         | `password123`                 |
| `mssql_server_url`            | SQL Server URL            | `server.database.windows.net` |
| `using_existing_sql_server`   | Use existing database     | `true`                        |
| `dns_zone_name`               | DNS zone for webapp       | `example.com`                 |

## Terraform Commands

| Command              | Description                  | When to Use      |
|---------             |-------------                 |-------------     |
| `terraform init`     | Initialize working directory | First time setup |
| `terraform fmt`      | Format configuration         | Before commits   |
| `terraform validate` | Verify configuration         | Before `plan`    |
| `terraform plan`     | Preview changes              | Before `apply`   |
| `terraform apply`    | Apply changes                | To deploy        |
| `terraform destroy`  | Remove resources             | To clean up      |

<br>
> ⚠️ **Warning**: Always run `terraform destroy` when you need to remove deployed resources to avoid unnecessary charges.


<br><br>
**Note:** Keep this documentation updated as the module evolves. Last updated: 2024