# ============================================================
# INFRASTRUCTURE (always provisioned)
# ============================================================

# --- Resource Group ---
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

# --- Storage Account ---
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# --- Blob Container ---
resource "azurerm_storage_container" "cicd" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# ============================================================
# IDENTITY (always provisioned)
# ============================================================

# --- Azure AD App Registrations ---
resource "azuread_application" "this" {
  for_each = var.service_principals

  display_name     = each.value.display_name
  description      = each.value.description
  sign_in_audience = "AzureADMyOrg"
}

# --- Service Principals (backed by App Registrations) ---
resource "azuread_service_principal" "this" {
  for_each = var.service_principals

  client_id = azuread_application.this[each.key].client_id
}

# --- Role Assignment: SP gets Storage Blob Data Contributor on the storage account ---
resource "azurerm_role_assignment" "blob_contributor" {
  for_each = var.service_principals

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.this[each.key].object_id
}

# ============================================================
# CLIENT SECRET AUTH (enable_client_secret_auth = true)
# ============================================================

resource "azuread_application_password" "this" {
  for_each = var.enable_client_secret_auth ? var.service_principals : {}

  application_id = azuread_application.this[each.key].id
  display_name   = "${each.value.display_name}-secret"
  end_date       = each.value.secret_expiry
}

# ============================================================
# FEDERATED AUTH / OIDC (enable_federated_auth = true)
# ============================================================

locals {
  federated_sps = var.enable_federated_auth ? {
    for k, v in var.service_principals : k => v
    if v.github_repo != null
  } : {}
}

# --- GitHub Repositories ---
resource "github_repository" "this" {
  for_each = var.enable_federated_auth ? var.github_repositories : {}

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility
}

# --- GitHub Environments per SP ---
resource "github_repository_environment" "this" {
  for_each = local.federated_sps

  repository  = each.value.github_repo
  environment = each.value.github_environment
}

# --- Federated Identity Credentials ---
resource "azuread_application_federated_identity_credential" "this" {
  for_each = local.federated_sps

  application_id = azuread_application.this[each.key].id
  display_name   = "${each.key}-federated"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_owner}/${each.value.github_repo}:environment:${each.value.github_environment}"
}
