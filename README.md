# Windows Server 2022 DevOps Agent Image Builder

This repository contains Packer configuration to build a custom Windows Server 2022 image with DevOps agent capabilities in Azure.

## Prerequisites

- [Packer](https://www.packer.io/downloads) installed on your local machine
- Azure subscription
- Azure Service Principal with appropriate permissions to create and manage resources
- Azure CLI installed and configured (optional, for easier authentication)

## Required Variables

The following variables need to be set before running Packer:

- `client_id`: Azure Service Principal App ID
- `client_secret`: Azure Service Principal Secret
- `subscription_id`: Azure Subscription ID
- `tenant_id`: Azure Tenant ID
- `resource_group`: Resource group to build in and save the image
- `location`: Azure region to build the image in (default: "East US")
- `image_name`: Name for the output managed image (default: "win2022-devops-agent")
- `image_version`: Version of the image (default: "1.0.0")

## Configuration

1. Copy the example variables file:
   ```bash
   cp example.pkrvars.hcl your-variables.pkrvars.hcl
   ```

2. Edit `your-variables.pkrvars.hcl` and fill in your Azure credentials and desired configuration.

## Building the Image

To build the image, run:

```bash
packer build -var-file="your-variables.pkrvars.hcl" windows-server-2022.pkr.hcl
```

## What's Included

The built image includes:
- Windows Server 2022 Datacenter Edition
- Google Chrome browser
- Azure VM Agent
- Sysprep configuration for deployment

## Output

After successful build, you'll find a managed image in your specified Azure resource group with the name format: `{image_name}-{image_version}`.

## Security Notes

- Never commit your `*.pkrvars.hcl` file containing sensitive credentials
- Consider using Azure Key Vault or environment variables for sensitive values
- The Service Principal should have minimum required permissions

## Troubleshooting

If you encounter issues:
1. Ensure all prerequisites are met
2. Verify your Azure credentials are correct
3. Check that the resource group exists and is accessible
4. Ensure you have sufficient permissions in your Azure subscription
