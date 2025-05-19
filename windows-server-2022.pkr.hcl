packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

variable "client_id" {
  type        = string
  description = "Azure Service Principal App ID"
}

variable "client_secret" {
  type        = string
  description = "Azure Service Principal Secret"
  sensitive   = true
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "resource_group" {
  type        = string
  description = "Resource group to build in and save the image"
}

variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region to build the image in"
}

variable "image_name" {
  type        = string
  default     = "win2022-devops-agent"
  description = "Name for the output managed image"
}

variable "image_version" {
  type        = string
  default     = "1.0.0"
  description = "Version of the image"
}

# Define the source for the build
source "azure-arm" "windows2022" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  managed_image_resource_group_name = var.resource_group
  managed_image_name                = "${var.image_name}-${var.image_version}"

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2022-Datacenter"

  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "5m"
  winrm_username = "packer"

  location = var.location
  vm_size  = "Standard_D2_v3"
}

# Build definition
build {
  name    = "windows-2022-devops-agent"
  sources = ["source.azure-arm.windows2022"]

# Install Chocolatey
  provisioner "powershell" {
    inline = [
      "$ProgressPreference = 'SilentlyContinue'",
      "Set-ExecutionPolicy Bypass -Scope Process -Force",
      "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072",
      "iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))",
      "choco feature enable -n allowGlobalConfirmation"
    ]
  }

  # Install Google Chrome
  provisioner "powershell" {
    inline = [
      "$ProgressPreference = 'SilentlyContinue'",
      "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile 'C:\\chrome_installer.exe'",
      "Start-Process -FilePath 'C:\\chrome_installer.exe' -Args '/silent /install' -Wait",
      "Remove-Item 'C:\\chrome_installer.exe'"
    ]
  }

  # Sysprep the VM for deployment
  provisioner "powershell" {
    inline = [
      "# If Guest Agent services are installed, make sure that they have started.",
      "foreach ($service in Get-Service -Name RdAgent, WindowsAzureTelemetryService, WindowsAzureGuestAgent -ErrorAction SilentlyContinue) { while ((Get-Service $service.Name).Status -ne 'Running') { Start-Sleep -s 5 } }",

      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}