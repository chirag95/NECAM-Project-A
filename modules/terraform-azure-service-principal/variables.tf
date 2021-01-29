variable "application_name" {
    description = "(Required) The name of the Azure AD Application to be created for which Service Principal will be created."
    type = string
    default = "sample"
}

variable "app_role_assignment_required" {
    description = "(Optional) Does this Service Principal require an AppRoleAssignment to a user or group before Azure AD will issue a user or access token to the application? Defaults to false."
    type = bool
    default = false
}

variable "tags" {
    description = "(Optional) A list of tags to apply to the Service Principal."
    type = list(string)
    default = []
}

variable "end_date"{
    description = "The End Date which the Password is valid until, formatted as a RFC3339 date string."
    type = string
    default = "2299-12-30T23:00:00Z"
}