variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-service-accounts"
}

# --- Storage ---
variable "storage_account_name" {
  description = "Globally unique storage account name (3-24 chars, lowercase alphanumeric only)"
  type        = string
}

variable "storage_container_name" {
  description = "Name of the blob container for CI/CD test writes"
  type        = string
  default     = "cicd-test"
}

# --- Service Principals (Azure AD App Registrations) ---
variable "service_principals" {
  description = "Map of service principals to create"
  type = map(object({
    display_name   = string
    description    = string
    secret_expiry  = string # RFC3339 date, e.g. "2027-01-01T00:00:00Z"
  }))
  default = {
    app_sp = {
      display_name  = "sp-app"
      description   = "Service principal for application access"
      secret_expiry = "2027-01-01T00:00:00Z"
    }
  }
}
