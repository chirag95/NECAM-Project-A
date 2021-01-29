variable "environment" {
  type = string
}

variable "stack" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  description = "Azure location for SQL Server."
  type        = string
}

variable "name_suffix" {
  description = "Optional suffix for the generated name"
  type        = string
  default     = ""
}

variable "server_version" {
  description = "Version of the SQL Server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)."
  type        = string
  default     = "12.0"
}

variable "allowed_cidr_list" {
  description = "Allowed IP addresses to access the server in CIDR format. Default to all Azure services"
  type        = list(string)
  default     = ["0.0.0.0/32"]
}

variable "extra_tags" {
  description = "Extra tags to add"
  type        = map(string)
  default     = {}
}

variable "server_extra_tags" {
  description = "Extra tags to add on SQL Server"
  type        = map(string)
  default     = {}
}

variable "databases_extra_tags" {
  description = "Extra tags to add on the SQL databases"
  type        = map(string)
  default     = {}
}

variable "server_custom_name" {
  description = "Name of the SQL Server, generated if not set."
  type        = string
  default     = ""
}

variable "administrator_login" {
  description = "Administrator login for SQL Server"
  type        = string
}

variable "administrator_password" {
  description = "Administrator password for SQL Server"
  type        = string
}

variable "nb_database" {
  description = "Number of the databases to create for this server"
  type        = number
  default = 1
}

variable "databases_collation" {
  description = "SQL Collation for the databases"
  type        = string
  default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
}

variable "enable_advanced_data_security" {
  description = "Boolean flag to enable Advanced Data Security. The cost of ADS is aligned with Azure Security Center standard tier pricing."
  type        = bool
  default     = false
}

variable "enable_advanced_data_security_admin_emails" {
  description = "Boolean flag to define if account administrators should be emailed with Advanced Data Security alerts."
  type        = bool
  default     = false
}

variable "advanced_data_security_additional_emails" {
  description = "List of additional email addresses for Advanced Data Security alerts."
  type        = list(string)
  default = ["nec@azure.com"]
}

variable "create_databases_users" {
  description = "True to create a user named <db>_user per database with generated password and role db_owner."
  type        = bool
  default     = true
}

variable "daily_backup_retention" {
  description = "Retention in days for the databases backup. Value can be 7, 14, 21, 28 or 35."
  type        = number
  default     = 35
}

variable "weekly_backup_retention" {
  description = "Retention in weeks for the weekly databases backup."
  type        = number
  default     = 0
}

variable "monthly_backup_retention" {
  description = "Retention in months for the monthly databases backup."
  type        = number
  default     = 3
}

variable "yearly_backup_retention" {
  description = "Retention in years for the yearly backup."
  type        = number
  default     = 0
}

variable "yearly_backup_time" {
  description = "Week number taken in account for the yearly backup retention."
  type        = number
  default     = 52
}

variable "requested_service_objective_name" {
  description = "(Optional) The service objective name for the database. Valid values depend on edition and location and may include S0, S1, S2, S3, P1, P2, P4, P6, P11 and ElasticPool. You can list the available names with the cli: shell az sql db list-editions -l westus -o table."
  type = string
  default = "ElasticPool"
}

variable "db_read_scale" {
  description = "(Optional) Read-only connections will be redirected to a high-available replica."
  type = bool
  default = false
}