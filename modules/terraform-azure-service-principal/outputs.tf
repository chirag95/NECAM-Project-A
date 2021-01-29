output "object_id" {
    value = azuread_service_principal.sp.object_id
}

output "application_id" {
    value = azuread_service_principal.sp.application_id
}

output "client_id" {
    value = azuread_service_principal.sp.application_id
}

output "client_secret" {
  value = random_string.password.result
  sensitive = false # Note that you might not want to print this in out in the console all the time
}