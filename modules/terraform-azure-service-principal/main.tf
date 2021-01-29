resource "azuread_application" "sp" {
  display_name                       = var.application_name
}

resource "azuread_service_principal" "sp" {
  application_id               = azuread_application.sp.application_id
  app_role_assignment_required = var.app_role_assignment_required

  tags = var.tags
}

resource "random_string" "password" {
  length  = 32
  special = true
}

# Create Service Principal password
resource "azuread_service_principal_password" "sp" {
  end_date             = var.end_date                       
  service_principal_id = azuread_service_principal.sp.id
  value                = random_string.password.result
}