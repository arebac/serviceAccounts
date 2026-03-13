# --- Auth Method Flags ---
variable "enable_client_secret_auth" {
  description = "Provision client secret credentials for each service principal"
  type        = bool
  default     = false
}

variable "enable_federated_auth" {
  description = "Provision OIDC federated credentials and GitHub environments for each service principal"
  type        = bool
  default     = true
}

# --- Azure ---
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

variable "storage_account_name" {
  description = "Globally unique storage account name (3-24 chars, lowercase alphanumeric only)"
  type        = string
}

variable "storage_container_name" {
  description = "Name of the blob container for CI/CD test writes"
  type        = string
  default     = "cicd-test"
}

# --- Service Principals ---
variable "service_principals" {
  description = "Map of service principals to create"
  type = map(object({
    display_name       = string
    description        = string
    secret_expiry      = optional(string, null)        # required when enable_client_secret_auth = true
    github_repo        = optional(string, null)        # required when enable_federated_auth = true
    github_environment = optional(string, "production")
  }))
  default = {
    app_sp = {
      display_name       = "sp-app"
      description        = "Service principal for application access"
      secret_expiry      = "2027-01-01T00:00:00Z"
      github_repo        = "serviceAccounts"
      github_environment = "production"
    }
  }
}

# --- GitHub ---
variable "github_owner" {
  description = "GitHub org or username that owns the repositories"
  type        = string
  default     = ""
}

variable "github_repositories" {
  description = "GitHub repositories to create and manage via Terraform"
  type = map(object({
    description = optional(string, "")
    visibility  = optional(string, "private")
  }))
  default = {}
}
