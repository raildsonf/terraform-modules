output "static-site-endpoint" {
  value = azurerm_storage_account.main.primary_web_endpoint
}
output "cdn_endpoint_fqdn" {
  value = "https://${azurerm_cdn_endpoint.main.fqdn}"
}