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