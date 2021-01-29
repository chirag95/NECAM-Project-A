# COMMON

variable "location" {
  description = "Azure location."
  type        = string
}

variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = string
  default     = ""
}

variable "app_gateway_tags" {
  description = "Application Gateway tags."
  type        = map(string)
  default     = {}
}

variable "extra_tags" {
  description = "Extra tags to add"
  type        = map(string)
  default     = {}
}

# PUBLIC IP

variable "ip_name" {
  description = "Public IP name."
  type        = string
  default     = ""
}

variable "ip_tags" {
  description = "Public IP tags."
  type        = map(string)
  default     = {}
}

variable "ip_label" {
  description = "Domain name label for public IP."
  type        = string
  default     = ""
}

variable "ip_sku" {
  description = "SKU for the public IP. Warning, can only be `Standard` for the moment."
  type        = string
  default     = "Standard"
}

variable "ip_allocation_method" {
  description = "Allocation method for the public IP. Warning, can only be `Static` for the moment."
  type        = string
  default     = "Static"
}

### APPGW NETWORK

variable "app_gateway_subnet_id" {
  description = "Application Gateway subnet ID."
  type        = string
  default     = null
}

# Application gateway inputs

variable "appgw_name" {
  description = "Application Gateway name."
  type        = string
  default     = ""
}

variable "sku_capacity" {
  description = "The Capacity of the SKU to use for this Application Gateway - which must be between 1 and 32 for V1 or between 1 and 125 for V2, optional if autoscale_configuration is set"
  type        = number
  default     = 2
}

variable "sku" {
  description = "The Name of the SKU to use for this Application Gateway. Possible values are Standard_v2 and WAF_v2."
  type        = string
  default     = "WAF_v2"
}

variable "autoscale_configuration" {
  description = "Autoscaling configuration for the application gateway"
  type        = list(map(string))
  default     = []
}

variable "enable_http2" {
  description = "Enable HTTP2"
  type        = bool
  default     = true
}

variable "frontend_ip_configuration_name" {
  description = "The Name of the Frontend IP Configuration used for this HTTP Listener."
  type        = string
  default     = ""
}

variable "frontend_private_ip_address" {
  description = "The private IP address to be used for the Frontend IP Configuration of this HTTP Listener."
  default     = null
}

variable "frontend_private_ip_address_allocation" {
  description = "The allocation method to be used for frontend private IP address. Can be Static or Dynamic. Only Static IP can be used with v2 tiers."
  default     = null
}

variable "enable_frontend_public_ip" {
  description = "Whether public ip should be configured for the frontend IP."
  type        = bool
  default     = false
}

variable "gateway_ip_configuration_name" {
  description = "The Name of the Application Gateway IP Configuration."
  type        = string
  default     = ""
}

variable "frontend_port_settings" {
  description = "Frontend port settings. Each port setting contains the name and the port for the frontend port."
  type        = list(map(string))
}

variable "ssl_policy" {
  description = "Application Gateway SSL configuration. The list of available policies can be found here: https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview#predefined-ssl-policy"
  type        = any
  default     = []
}

variable "trusted_root_certificate_configs" {
  description = "List of trusted root certificates. The needed values for each trusted root certificates are 'name' and 'data'."
  type        = list(map(string))
  default     = []
}

variable "appgw_backend_pools" {
  description = "List of maps including backend pool configurations"
  type        = any
}

variable "appgw_http_listeners" {
  description = "List of maps including http listeners configurations"
  type        = list(map(string))
}

variable "ssl_certificates_configs" {
  description = "List of maps including ssl certificates configurations"
  type        = list(map(string))
  default     = []
}

variable "appgw_routings" {
  description = "List of maps including request routing rules configurations"
  type        = list(map(string))
}

variable "appgw_probes" {
  description = "List of maps including request probes configurations"
  type        = any
  default     = [{
      host                                      = null
      interval                                  = 30  
      path                                      = "/" #The Path used for this Probe.
      protocol                                  = "Https"
      timeout                                   = 30
      pick_host_name_from_backend_http_settings = true  #Whether the host header should be picked from the backend http settings. 
      unhealthy_threshold                       = 3
      match_body                                = ""  #A snippet from the Response Body which must be present in the Response
      match_status_code                         = ["200-399"]  #A list of allowed status codes for this Health Probe.
  }]
}

variable "appgw_backend_http_settings" {
  description = "List of maps including backend http settings configurations"
  type        = any
}

variable "appgw_url_path_map" {
  description = "List of maps including url path map configurations"
  type        = any
  default     = []
}

variable "appgw_redirect_configuration" {
  description = "List of maps including redirect configurations"
  type        = list(map(string))
  default     = []
}

### REWRITE RULE SET

variable "appgw_rewrite_rule_set" {
  description = "List of rewrite rule set including rewrite rules"
  type        = any
  default     = []
}

### WAF

variable "enable_waf" {
  description = "Boolean to enable WAF."
  type        = bool
  default     = true
}

variable "file_upload_limit_mb" {
  description = " The File Upload Limit in MB. Accepted values are in the range 1MB to 500MB. Defaults to 100MB."
  type        = number
  default     = 100
}

variable "waf_mode" {
  description = "The Web Application Firewall Mode. Possible values are Detection and Prevention."
  type        = string
  default     = "Prevention"
}

variable "max_request_body_size_kb" {
  description = "The Maximum Request Body Size in KB. Accepted values are in the range 1KB to 128KB."
  type        = number
  default     = 128
}

variable "request_body_check" {
  description = "Is Request Body Inspection enabled?"
  type        = bool
  default     = true
}

variable "rule_set_type" {
  description = "The Type of the Rule Set used for this Web Application Firewall."
  type        = string
  default     = "OWASP"
}

variable "rule_set_version" {
  description = "The Version of the Rule Set used for this Web Application Firewall. Possible values are 2.2.9, 3.0, and 3.1."
  type        = number
  default     = 3.1
}

variable "disabled_rule_group_settings" {
  description = "The rule group where specific rules should be disabled.  Accepted values are: crs_20_protocol_violations, crs_21_protocol_anomalies, crs_23_request_limits, crs_30_http_policy, crs_35_bad_robots, crs_40_generic_attacks, crs_41_sql_injection_attacks, crs_41_xss_attacks, crs_42_tight_security, crs_45_trojans, General, REQUEST-911-METHOD-ENFORCEMENT, REQUEST-913-SCANNER-DETECTION, REQUEST-920-PROTOCOL-ENFORCEMENT, REQUEST-921-PROTOCOL-ATTACK, REQUEST-930-APPLICATION-ATTACK-LFI, REQUEST-931-APPLICATION-ATTACK-RFI, REQUEST-932-APPLICATION-ATTACK-RCE, REQUEST-933-APPLICATION-ATTACK-PHP, REQUEST-941-APPLICATION-ATTACK-XSS, REQUEST-942-APPLICATION-ATTACK-SQLI, REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION"
  type = list(object({
    rule_group_name = string
    rules           = list(string)
  }))
  default = []
}

variable "waf_exclusion_settings" {
  description = "WAF exclusion rules to exclude header, cookie or GET argument."
  type        = list(map(string))
  default     = []
}

### NETWORKING

variable "virtual_network_name" {
  description = "Virtual network name to attach the subnet."
  type        = string
}

variable "subnet_resource_group_name" {
  description = "Resource group name of the subnet."
  type        = string
  default     = ""
}

variable "create_subnet" {
  description = "Boolean to create subnet with this module."
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "Custom subnet ID for attaching the Application Gateway. Used only when the variable `create_subnet = false`."
  type        = string
  default     = ""
}

variable "route_table_ids" {
  description = "The Route Table Ids map to associate with the subnets."
  type        = map(string)
  default     = {}
}

variable "custom_subnet_name" {
  description = "Custom name for the subnet."
  type        = string
  default     = ""
}

variable "subnet_cidr" {
  description = "Subnet CIDR to create."
  type        = string
  default     = ""
}

variable "create_nsg" {
  description = "Boolean to create the network security group."
  type        = bool
  default     = true
}

variable "create_nsg_https_rule" {
  description = "Boolean to create the network security group rule opening https to everyone."
  type        = bool
  default     = true
}

variable "create_nsg_healthprobe_rule" {
  description = "Boolean to create the network security group rule for the health probes."
  type        = bool
  default     = true
}

variable "custom_nsg_name" {
  description = "Custom name for the network security group."
  type        = string
  default     = null
}

variable "custom_nsr_https_name" {
  description = "Custom name for the network security rule for HTTPS protocol."
  type        = string
  default     = null
}

variable "custom_nsr_healthcheck_name" {
  description = "Custom name for the network security rule for internal health check of Application Gateway."
  type        = string
  default     = null
}

variable "create_network_security_rules" {
  description = "Boolean to define is default network security rules should be create or not. Default rules are for port 443 and for the range of ports 65200-65535 for Application Gateway healthchecks."
  type        = bool
  default     = true
}

variable "nsr_https_source_address_prefix" {
  description = "Source address prefix to allow to access on port 443 defined in dedicated network security rule."
  type        = string
  default     = "*"
}

### IDENTITY

variable "user_assigned_identity_id" {
  description = "User assigned identity id assigned to this resource"
  type        = string
  default     = null
}
