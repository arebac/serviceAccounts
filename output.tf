# --- Storage Outputs ---
output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "storage_container_name" {
  description = "Name of the blob container"
  value       = azurerm_storage_container.cicd.name
}

output "storage_blob_endpoint" {
  description = "Primary blob service endpoint"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

# --- Service Principal Outputs ---
output "service_principal_client_ids" {
  description = "Client IDs (app IDs) of the service principals"
  value       = { for k, v in azuread_application.this : k => v.client_id }
}

output "service_principal_object_ids" {
  description = "Object IDs of the service principals"
  value       = { for k, v in azuread_service_principal.this : k => v.object_id }
}

output "service_principal_client_secrets" {
  description = "Client secrets for each service principal"
  sensitive   = true
  value       = { for k, v in azuread_application_password.this : k => v.value }
}
