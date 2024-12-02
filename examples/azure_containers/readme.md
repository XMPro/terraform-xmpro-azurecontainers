# XMPro - Azure Containers Terraform Module

## Overview
This Terraform module facilitates the deployment of XMPRo resources on Azure using Terraform CLI commands. It is designed for a fresh installation of all XMPRo products, including the necessary infrastructure and configurations. The module allows you to customize various parameters such as resource names, environment settings, and resource allocations to suit your specific deployment needs. By using this module, you can ensure a consistent and repeatable setup process for XMPRo products in your Azure environment.

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
   > ⚠️ **Security Warning**: 
   > - Never commit `az.env` to version control
   > - Consider using `az account show` to get credentials

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
   cd /path/to/xmpro-development/deploy/terraform/examples/azure_containers
   ```

2. **Run Docker Container**
   ```bash
   docker run -it --rm \
     --env-file az.env \
     -v <path-to-git-repo>:/opt/terraform \
     xmpro.azurecr.io/xmterraform
   ```
   Example `<path-to-git-repo>` : 
   `F:\projects\xmpro-development`

3. **Navigate Inside Container**
   ```bash
   cd deploy/terraform/examples/azure_containers
   ```

## Configuration

### Key Variables

Update the following variables in `main.tf` according to your requirements:

| Variable                      | Description               | Required | Default                       |
|----------                     |-------------              | -------- |----------                     |
| `prefix`                      | Resource prefix           |    No    | `xmdemo`                      |
| `environment`                 | Deployment environment    |    No    | `jonahf`                      |
| `location`                    | Azure region              |    No    | `australiaeast`               |
| `companyname`                 | Company name in database  |    No    | `xmrrdev`                     |
| `db_admin_username`           | Database admin username   |    No    | `xmadmin`                     |
| `db_admin_password`           | Database admin password   |    Yes   | `<min-8-chars-complex`        |
| `company_admin_password`      | Company admin password    |    Yes   | `<min-8-chars-complex`        |
| `site_admin_password`         | Site admin password       |    Yes   | `<min-8-chars-complex`        |
| `dns_zone_name`               | DNS zone for webapp       |    No    | `example.com`                 |

> Note: Sensitive credentials are now managed through Azure Key Vault

<br>

> 🔒 **Security Notes**:
> 1. **Credential Management**
>    - Never commit sensitive values to version control
>    - Use environment variables or secure vaults
>    - Rotate credentials regularly
>
> 2. **Password Requirements** 
>    - Length:8-16 characters
>    - Avoid default/weak passwords
>    - Include mix of uppercase, lowercase, numbers and symbols
>
> 3. **Best Practices**
>    - Use separate credentials per environment
>    - Follow principle of least privilege
>    - Enable MFA where possible

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