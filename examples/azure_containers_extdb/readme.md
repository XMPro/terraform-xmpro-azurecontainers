# XMPro - Azure Containers External Database Terraform Module

## Overview
This Terraform module deploys and manages XMPro resources on Azure using an existing external database. It provides customization options for resource names, environment settings, and resource allocations.

> 💡 **Tip**: Press `Ctrl + Shift + V` in VS Code to preview this Markdown file.

## Prerequisite

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
   # Required Azure credentials
   ARM_TENANT_ID=<your-tenant-id>         # Find this in Azure Portal > Azure Active Directory
   ARM_SUBSCRIPTION_ID=<your-subscription-id>  # Find this in Azure Portal > Subscriptions
   ```

   > 🔒 **Security Best Practices**:
   > 1. **Never commit credentials to Git**
   >    - Add `*.env` to your `.gitignore`
   >    - Keep sensitive values out of version control
   >
   > 2. **Secure Storage**
   >    - Use Azure Key Vault for credential storage
   >    - Consider using Azure Managed Identities
   >
   > 3. **Credential Management**
   >    - Rotate credentials regularly
   >    - Use separate credentials for each environment
   >    - Follow the principle of least privilege

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
      --env-file az.env \
      -v <path-to-git-repo>:/opt/terraform \
      xmpro.azurecr.io/xmterraform

   # Example paths:
   # On Windows: -v C:/Users/username/repos/xmpro-development:/opt/terraform
   # On Linux: -v /home/username/xmpro-development:/opt/terraform
   ```
   

3. **Navigate Inside Container**
   ```bash
   cd deploy/terraform/examples/azure_containers_extdb
   ```

## Configuration

### Key Variables

Update the following variables in `main.tf` according to your requirements:

| Variable                      | Description               | Required | Default                                      |
|----------                     |-------------              | -------- |----------                                    |
| `prefix`                      | Resource prefix           |    No    | `xmdemo`                                     |
| `environment`                 | Deployment environment    |    No    | `jonahf`                                     |
| `location`                    | Azure region              |    No    | `australiaeast`                              |
| `companyname`                 | Company name in database  |    No    | `xmrrdev`                                    |
| `db_admin_username`           | Database username         |    No    | `xmadmin`                                    |
| `db_admin_password`           | Database password         |    Yes   | `<use-secure-password>`                      |
| `company_admin_password`      | Database password         |    Yes   | `<use-secure-password>`                      |
| `site_admin_password`         | Database password         |    Yes   | `<use-secure-password>`                      |
| `dns_zone_name`               | DNS zone for webapp       |    No    | `example.com`                                |
| `using_existing_sql_server`   | Use existing database     |    No    | `false`                                      |
| `existing_sql_server_url`     | SQL Server URL            |    No    | ``                                           |

> 🔒 **Security Note**: Never commit sensitive values to version control. Use environment variables or secure vaults.
> 🔒 **Security Note**: Password should be at 8 to 16 characters long.
> 🔒 **Security Note**: Please dont use default password for better security.

> Note: Sensitive credentials are now managed through Azure Key Vault

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