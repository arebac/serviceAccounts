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

# --- Role Assignment: SP gets Storage Blob Data Contributor on the container ---
resource "azurerm_role_assignment" "blob_contributor" {
  for_each = var.service_principals

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.this[each.key].object_id
}

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

# --- Client Secret per Service Principal ---
resource "azuread_application_password" "this" {
  for_each = var.service_principals

  application_id = azuread_application.this[each.key].id
  display_name   = "${each.value.display_name}-secret"
  end_date       = each.value.secret_expiry
}
