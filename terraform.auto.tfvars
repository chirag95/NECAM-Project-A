common_resource_location = "usgovvirginia"
subscription_id          ="4e722558-d33b-4eda-875f-db29b0c58eee"
tenant_id                ="0a6c2227-7301-4d7f-ab67-74f492171b8a"
client_id                = "010629cd-441e-45df-91bc-863bd57a27d7"
client_secret            = "GsxVDhKJ68M54u~B~~K0b2xq4-.UQ1Gt7~"

#--------------------------------
# Common Tags
#--------------------------------
common_tags={"team":"Cloud Team"}


#--------------------------------
# Module = resgp
#--------------------------------
use_existing_resource_group = false
resource_group_name         = ""#"nci-automation-rg"
region                      = "usgovtexas" #Resource Group Location
resource_group_tags         = {}

#--------------------------------
# Module = network
#--------------------------------
  network_location   = null
  vnet_name_suffix   = ""
  address_space      = ["10.0.0.0/8"] #, "ffff:a01::/56"]
  dns_servers        = []
  subnet_prefixes    = ["10.0.1.0/24", "10.0.2.0/24", "10.1.0.0/16", "10.2.0.0/16"] #, "ffff:a01:100::/64"]
  subnet_name_suffix = ""
  # subnet_names    = ["subnet1", "subnet2", "subnet3"]#, "subnet4"]
  vnet_tags = {
    environment = "dev"
  }

  enable_bastion                      = false
  azure_bastion_service_name_suffix   = ""
  azure_bastion_subnet_address_prefix = ["10.0.4.0/24"]
  public_ip_allocation_method         = "Static"
  public_ip_sku                       = "Standard"
  bastion_tags = {
    environment = "dev"
  }

  enable_firewall_for_vnet = false
  # firewall_public_ip_name = "newip"
  firewall_public_ip_allocation_method = "Static"
  firewall_public_ip_sku               = "Standard"
  azure_firewall_subnet_address_prefix = "10.0.5.0/24"
  firewall_tags = {
    environment = "dev"
  }
  firewall_suffix = ""

  create_ddos_plan      = false
  ddos_plan_name_suffix = ""
  ddos_resource_tags = {
    environment = "dev"
  }

#--------------------------------
# Module = compute
#--------------------------------
  vm_config = [
    {   
        vm_hostname_identifier = "EN-SCSB"
        vm_location = ""
        vnet_subnet_index      = 0
        public_ip_dns          = [null]
        admin_password         = "Nec@123"
        enable_ssh_key         = false
        generate_admin_ssh_key = false
        ssh_key                = "./id-rsa.pub"
        nsg_rules = {
          allow_ssh = {
            priority         = 100
            protocol         = "TCP"
            destination_port = "22"
            source_address   = "10.0.0.0/8"
            access           = "Allow"
            direction        = "Inbound"
          }
        }
        admin_username       = "azureuser"
        custom_data          = ""
        storage_account_type = "Standard_LRS"
        storage_data_disk = [{
          create_option     = "Empty"        #(Required) Possible values are Attach, FromImage and Empty.
          disk_size_gb      = 30             #(Required) Specifies the size of the data disk in gigabytes.
          managed_disk_type = "Standard_LRS" #Value must be either Standard_LRS or Premium_LRS.
        }]
        delete_os_disk_on_termination   = true
        delete_data_disk_on_termination = true
        vm_size                         = "Standard_B1s"
        nb_instances                    = 1
        vm_os_simple                    = "CentOS"
        vm_os_version                   = "latest"
        vm_tags = {
          source = "terraform"
        }
        vm_public_ip_allocation_method = "Static"
        vm_nb_public_ip                = 1
        vm_public_ip_sku               = "Standard"
        # private_ips                    = ["10.0.1.5", "10.0.1.6"]

        boot_diagnostics                    = true
        boot_diagnostics_sa_type            = "Standard_LRS"
        enable_accelerated_networking       = false
        source_address_prefixes             = ["0.0.0.0/0"]
        license_type                        = null
        identity_type                       = "SystemAssigned" #null
        identity_ids                        = []               # reqd when identity_type=UserAssigned
        create_availability_set             = true
        av_set_platform_fault_domain_count  = 2
        av_set_platform_update_domain_count = 2
        av_set_managed                      = true
        av_set_tags                         = {}
        #proximity_placement_group_name      = ""

        #-----load balancer
        loadbalancer_prefix  = ""
        load_balancer_sku    = "Standard"
        enable_load_balancer = true
        load_balancer_type   = "public"
        lb_remote_port = {
          ssh = ["Tcp", "22"]
        }
        lb_port = {
          http  = ["80", "Tcp", "80"]
          https = ["443", "Tcp", "443"]
        }
        lb_probe = {
          http  = ["Tcp", "80", ""]
          http2 = ["Http", "1443", "/"]
        }
        lb_probe_unhealthy_threshold = 2
        lb_probe_interval            = 5
        # lb_frontend_name_suffix             = ""
        lb_allocation_method                      = "Static"
        lb_frontend_private_ip_address            = ""
        lb_frontend_private_ip_address_allocation = "Dynamic"
        lb_public_ip_sku                          = "Standard"
        lb_tags = {
          source = "terraform"
        }
        lb_ipv4_tags = {
          source = "terraform"
        }
        enable_floating_ip = false
        #-----VM backup
        enable_vm_backup                  = false
        vm_recovery_vault_sku             = "Standard"
        backup_recovery_vault_name_suffix = ""
        timezone                          = "UTC"
        vm_backup = {
          frequency = "Daily"
          time      = "23:00"
          # weekdays = ["Sunday"]
        }
        vm_retention_daily_count = 7
        vm_retention_weekly      = null
        vm_retention_monthly = {
          count    = 7
          weekdays = ["Sunday", "Wednesday"]
        weeks = ["First", "Last"] }
        vm_retention_yearly = null

        #------VM auto shutdown
        enable_vm_autoshutdown                = true
        vm_autoshutdown_daily_recurrence_time = "1100"
        VM_shutdown_timezone                  = "UTC"
        vm_autoshutdown_notification_settings = {
          enabled         = true
          time_in_minutes = "60"
          webhook_url     = "https://sample-webhook-url.example.com"
        }

        #------OS diagnostics variables
        os_diagnostics_storage_account_type = "Standard_LRS"
        enable_os_diagnostics               = true
      },

    # {
    #     vm_hostname_identifier = "EN-WIN"  
    #     # vm_location = ""
    #     vnet_subnet_index      = 0
    #     public_ip_dns          = [null]
    #     admin_password         = "Nec@1234"
    #     enable_ssh_key         = false
    #     generate_admin_ssh_key = false
    #     ssh_key                = "./id-rsa.pub"
    #     nsg_rules = {
    #       allow_ssh = {
    #         priority         = 100
    #         protocol         = "TCP"
    #         destination_port = "22"
    #         source_address   = "10.0.0.0/8"
    #         access           = "Allow"
    #         direction        = "Inbound"
    #       }
    #     }
    #     admin_username       = "azureuser"
    #     custom_data          = ""
    #     storage_account_type = "Standard_LRS"
    #     storage_data_disk = [{
    #       create_option     = "Empty"        #(Required) Possible values are Attach, FromImage and Empty.
    #       disk_size_gb      = 30             #(Required) Specifies the size of the data disk in gigabytes.
    #       managed_disk_type = "Standard_LRS" #Value must be either Standard_LRS or Premium_LRS.
    #     }]
    #     delete_os_disk_on_termination   = true
    #     delete_data_disk_on_termination = true
    #     vm_size                         = "Standard_B1s"
    #     nb_instances                    = 2
    #     # vm_hostname                     = "host1"
    #     vm_os_simple                    = "WindowsServer"
    #     vm_os_version                   = "latest"
    #     vm_tags = {
    #       source = "terraform"
    #     }
    #     vm_public_ip_allocation_method = "Static"
    #     vm_nb_public_ip                = 1
    #     vm_public_ip_sku               = "Standard"
    #     # private_ips                    = ["10.0.1.5", "10.0.1.6"]

    #     boot_diagnostics                    = true
    #     boot_diagnostics_sa_type            = "Standard_LRS"
    #     enable_accelerated_networking       = false
    #     source_address_prefixes             = ["0.0.0.0/0"]
    #     license_type                        = null
    #     identity_type                       = "SystemAssigned" #null
    #     identity_ids                        = []               # reqd when identity_type=UserAssigned
    #     create_availability_set             = true
    #     av_set_platform_fault_domain_count  = 2
    #     av_set_platform_update_domain_count = 2
    #     av_set_managed                      = true
    #     av_set_tags                         = {}
    #  #   proximity_placement_group_name      = ""

    #     #-----load balancer
    #     loadbalancer_prefix  = ""
    #     load_balancer_sku    = "Standard"
    #     enable_load_balancer = true
    #     load_balancer_type   = "public"
    #     lb_remote_port = {
    #       ssh = ["Tcp", "22"]
    #     }
    #     lb_port = {
    #       http  = ["80", "Tcp", "80"]
    #       https = ["443", "Tcp", "443"]
    #     }
    #     lb_probe = {
    #       http  = ["Tcp", "80", ""]
    #       http2 = ["Http", "1443", "/"]
    #     }
    #     lb_probe_unhealthy_threshold = 2
    #     lb_probe_interval            = 5
    #     # lb_frontend_name_suffix             = ""
    #     lb_allocation_method                      = "Static"
    #     lb_frontend_private_ip_address            = ""
    #     lb_frontend_private_ip_address_allocation = "Dynamic"
    #     lb_public_ip_sku                          = "Standard"
    #     lb_tags = {
    #       source = "terraform"
    #     }
    #     lb_ipv4_tags = {
    #       source = "terraform"
    #     }
    #     enable_floating_ip = false

    #     #-----VM backup
    #     enable_vm_backup                  = false
    #     vm_recovery_vault_sku             = "Standard"
    #     backup_recovery_vault_name_suffix = ""
    #     timezone                          = "UTC"
    #     vm_backup = {
    #       frequency = "Daily"
    #       time      = "23:00"
    #       # weekdays = ["Sunday"]
    #     }
    #     vm_retention_daily_count = 7
    #     vm_retention_weekly      = null
    #     vm_retention_monthly = {
    #       count    = 7
    #       weekdays = ["Sunday", "Wednesday"]
    #     weeks = ["First", "Last"] }
    #     vm_retention_yearly = null

    #     #------VM auto shutdown
    #     enable_vm_autoshutdown                = true
    #     vm_autoshutdown_daily_recurrence_time = "1100"
    #     VM_shutdown_timezone                  = "UTC"
    #     vm_autoshutdown_notification_settings = {
    #       enabled         = true
    #       time_in_minutes = "60"
    #       webhook_url     = "https://sample-webhook-url.example.com"
    #     }

    #     #------OS diagnostics variables
    #       os_diagnostics_storage_account_type = "Standard_LRS"
    #       enable_os_diagnostics               = true
    #   },
    {   
        vm_hostname_identifier = "EN-SN"
        vm_location = ""
        vnet_subnet_index      = 0
        public_ip_dns          = [null]
        admin_password         = "Nec@123"
        enable_ssh_key         = false
        generate_admin_ssh_key = false
        ssh_key                = "./id-rsa.pub"
        nsg_rules = {
          allow_ssh = {
            priority         = 100
            protocol         = "TCP"
            destination_port = "22"
            source_address   = "10.0.0.0/8"
            access           = "Allow"
            direction        = "Inbound"
          }
        }
        admin_username       = "azureuser"
        custom_data          = ""
        storage_account_type = "Standard_LRS"
        storage_data_disk = [{
          create_option     = "Empty"        #(Required) Possible values are Attach, FromImage and Empty.
          disk_size_gb      = 30             #(Required) Specifies the size of the data disk in gigabytes.
          managed_disk_type = "Standard_LRS" #Value must be either Standard_LRS or Premium_LRS.
        }]
        delete_os_disk_on_termination   = true
        delete_data_disk_on_termination = true
        vm_size                         = "Standard_B1s"
        nb_instances                    = 2
        vm_os_simple                    = "CentOS"
        vm_os_version                   = "latest"
        vm_tags = {
          source = "terraform"
        }
        vm_public_ip_allocation_method = "Static"
        vm_nb_public_ip                = 1
        vm_public_ip_sku               = "Standard"
        # private_ips                    = ["10.0.1.5", "10.0.1.6"]

        boot_diagnostics                    = true
        boot_diagnostics_sa_type            = "Standard_LRS"
        enable_accelerated_networking       = false
        source_address_prefixes             = ["0.0.0.0/0"]
        license_type                        = null
        identity_type                       = "SystemAssigned" #null
        identity_ids                        = []               # reqd when identity_type=UserAssigned
        create_availability_set             = true
        av_set_platform_fault_domain_count  = 2
        av_set_platform_update_domain_count = 2
        av_set_managed                      = true
        av_set_tags                         = {}
        #proximity_placement_group_name      = ""

        #-----load balancer
        loadbalancer_prefix  = ""
        load_balancer_sku    = "Standard"
        enable_load_balancer = true
        load_balancer_type   = "public"
        lb_remote_port = {
          ssh = ["Tcp", "22"]
        }
        lb_port = {
          http  = ["80", "Tcp", "80"]
          https = ["443", "Tcp", "443"]
        }
        lb_probe = {
          http  = ["Tcp", "80", ""]
          http2 = ["Http", "1443", "/"]
        }
        lb_probe_unhealthy_threshold = 2
        lb_probe_interval            = 5
        lb_allocation_method                      = "Static"
        lb_frontend_private_ip_address            = ""
        lb_frontend_private_ip_address_allocation = "Dynamic"
        lb_public_ip_sku                          = "Standard"
        lb_tags = {
          source = "terraform"
        }
        lb_ipv4_tags = {
          source = "terraform"
        }
        enable_floating_ip = false
        #-----VM backup
        enable_vm_backup                  = false
        vm_recovery_vault_sku             = "Standard"
        backup_recovery_vault_name_suffix = ""
        timezone                          = "UTC"
        vm_backup = {
          frequency = "Daily"
          time      = "23:00"
          # weekdays = ["Sunday"]
        }
        vm_retention_daily_count = 7
        vm_retention_weekly      = null
        vm_retention_monthly = {
          count    = 7
          weekdays = ["Sunday", "Wednesday"]
        weeks = ["First", "Last"] }
        vm_retention_yearly = null

        #------VM auto shutdown
        enable_vm_autoshutdown                = true
        vm_autoshutdown_daily_recurrence_time = "1100"
        VM_shutdown_timezone                  = "UTC"
        vm_autoshutdown_notification_settings = {
          enabled         = true
          time_in_minutes = "60"
          webhook_url     = "https://sample-webhook-url.example.com"
        }

        #------OS diagnostics variables
        os_diagnostics_storage_account_type = "Standard_LRS"
        enable_os_diagnostics               = true
      }  
  ]
#--------------------------------
# Module = Application Gateway
#--------------------------------

  # COMMON
  app_gateway_tags       = {}
  app_gateway_extra_tags = {}
  appgw_location         = null
  # PUBLIC IP
  app_gateway_ip_name              = ""
  app_gateway_ip_tags              = {}
  app_gateway_ip_label             = ""
  app_gateway_ip_sku               = "Standard"
  app_gateway_ip_allocation_method = "Static"
  # Application gateway inputs
  appgw_name         = ""
  appgw_sku_capacity = null
  appgw_sku          = "WAF_v2"
  appgw_autoscale_configuration = [{
    min_capacity = "1"
    max_capacity = "4"
  }]
  appgw_enable_http2                           = false
  appgw_frontend_ip_configuration_name         = ""
  appgw_frontend_private_ip_address            = "10.0.2.2"
  appgw_frontend_private_ip_address_allocation = "Static"
  appgw_enable_frontend_public_ip              = true
  appgw_gateway_ip_configuration_name          = ""
  appgw_frontend_port_settings = [{
    name = "frontend-https-port"
    port = 443
  }]
  appgw_ssl_policy                       = [{
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
    min_protocol_version = "TLSv1_2"
  }]
  appgw_trusted_root_certificate_configs = []
  appgw_backend_pools = [{ 
    name  = "backendpool"
    fqdns = ["example.com"]
  }]
  appgw_http_listeners = [{
    name                           = "listener-https"
    frontend_ip_configuration_name = "frontipconfig"
    frontend_port_name             = "frontend-https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "test-example-com-sslcert"
    host_name                      = "example.com"
    require_sni                    = true
  }]
  ssl_certificates_config_name = "test-example-com-sslcert"
  ssl_certificate_path         = "./certificate.pfx"
  ssl_certificate_password     = "password"
  appgw_routings = [{
    name                       = "routing-https"
    rule_type                  = "Basic"
    http_listener_name         = "listener-https"
    backend_address_pool_name  = "backendpool"
    backend_http_settings_name = "backhttpsettings"
  }]
  appgw_probes = [{
    host                                      = null
    interval                                  = 30 #The Path used for this Probe.
    path                                      = "/"
    protocol                                  = "Https"
    timeout                                   = 30
    pick_host_name_from_backend_http_settings = true #Whether the host header should be picked from the backend http settings. 
    unhealthy_threshold                       = 3
    match_body                                = ""          #A snippet from the Response Body which must be present in the Response
    match_status_code                         = ["200-399"] #A list of allowed status codes for this Health Probe.
  }]
  appgw_backend_http_settings = [{
    name                  = "backhttpsettings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 300
  }]
  appgw_url_path_map           = []
  appgw_redirect_configuration = []
  ### REWRITE RULE SET
  appgw_rewrite_rule_set = []
  ### WAF
  appgw_enable_waf                   = true
  appgw_file_upload_limit_mb         = 100
  appgw_waf_mode                     = "Detection"
  appgw_max_request_body_size_kb     = 128
  appgw_request_body_check           = true
  appgw_rule_set_type                = "OWASP"
  appgw_rule_set_version             = 3.1
  appgw_disabled_rule_group_settings = []
  appgw_waf_exclusion_settings       = []
  ### LOGGING
  # appgw_enable_logging                  = false
  # appgw_diag_settings_name              = ""
  # appgw_logs_storage_retention          = 30
  # appgw_log_storage_account_type = "Standard_LRS"
  # appgw_log_analytics_workspace_sku = "PerGB2018"
  # appgw_eventhub_authorization_rule_id  = null
  ### NETWORKING
  appgw_subnet_resource_group_name      = ""
  appgw_create_subnet                   = false #true
  apgw_vnet_subnet_index                = 1     #Used only when the variable `create_subnet = false`
  appgw_route_table_ids                 = {}
  appgw_custom_subnet_name              = ""
  appgw_subnet_cidr                     = ""
  appgw_create_nsg                      = true
  appgw_create_nsg_https_rule           = true
  appgw_create_nsg_healthprobe_rule     = true
  appgw_custom_nsg_name                 = null
  appgw_custom_nsr_https_name           = null
  appgw_custom_nsr_healthcheck_name     = null
  appgw_create_network_security_rules   = true
  appgw_nsr_https_source_address_prefix = "*"
  ### IDENTITY
  appgw_user_assigned_identity_id = null
  #Either a `eventhub_authorization_rule_id`, `log_analytics_workspace_id` or `storage_account_id` must be set if logging is enabled

#-------------------------------
# Module: AKS
#-------------------------------
  node_resource_group                  = null
  aks_admin_username                   = "azureuser"
  aks_location                         = null
  aks_agents_size                      = "Standard_D2s_v3"
  # aks_log_analytics_workspace_sku      = "PerGB2018"
  # aks_log_retention_in_days            = 30
  aks_ssh_key                          = ""
  aks_use_existing_ssh_key             = false
  aks_windows_admin_password           = "Nci-automation@123"
  aks_tags                             = {}
  # aks_enable_log_analytics_workspace   = true
  aks_subnet_index                     = 2
  aks_sku_tier                         = "Free"
  aks_enable_role_based_access_control = true
  aks_rbac_aad_managed                 = null#true
  aks_rbac_aad_admin_group_object_ids  = ["4682f0c4-78e7-4294-8e65-db0f8cc6c8f4"]
  api_auth_ips                         = null#["45.26.119.59", "45.26.119.61", "143.101.0.0/16"] # Private cluster cannot be enabled with AuthorizedIPRanges.
  private_cluster                      = false                                              # Private cluster cannot be enabled with AuthorizedIPRanges.

  kubernetes_version = null
  default_node_pool = {
    name                           = "nodepool"
    node_count                     = 6
    vm_size                        = "Standard_B4ms"
    type                           = "VirtualMachineScaleSets" # or AvailabilitySets
    zones                          = null
    max_pods                       = 250
    os_disk_size_gb                = 50
    labels                         = null
    taints                         = null
    cluster_auto_scaling           = false
    cluster_auto_scaling_min_count = null #set it to null when cluster_auto_scaling=false
    cluster_auto_scaling_max_count = null #set it to null when cluster_auto_scaling=false
    enable_node_public_ip          = true
  }
  additional_node_pools = { #Windows agent pools can only be added to AKS clusters using Azure-CNI.
    # "pool2" = {
    #   node_count                     = 4
    #   vm_size                        = "Standard_D2s_v3"
    #   zones                          = null #["1", "2", "3"]
    #   max_pods                       = 250
    #   os_disk_size_gb                = 50
    #   labels                         = null
    #   taints                         = null
    #   node_os                        = "Linux"
    #   cluster_auto_scaling           = true
    #   cluster_auto_scaling_min_count = 1
    #   cluster_auto_scaling_max_count = 3
    #   enable_node_public_ip          = true
    # }
    # "pool3" = {
    #   node_count                     = 2
    #   vm_size                        = "Standard_B2s"
    #   zones                          = null #["1", "2", "3"]
    #   max_pods                       = 250
    #   os_disk_size_gb                = 50
    #   labels                         = null
    #   taints                         = null
    #   node_os                        = "Linux"
    #   cluster_auto_scaling           = true
    #   cluster_auto_scaling_min_count = 1
    #   cluster_auto_scaling_max_count = 3
    #   enable_node_public_ip          = true
    # }
    # "pool4" = {
    #   node_count                     = 2
    #   vm_size                        = "Standard_B2s"
    #   zones                          = null #["1", "2", "3"]
    #   max_pods                       = 250
    #   os_disk_size_gb                = 50
    #   labels                         = null
    #   taints                         = null
    #   node_os                        = "Windows"
    #   cluster_auto_scaling           = true
    #   cluster_auto_scaling_min_count = 1
    #   cluster_auto_scaling_max_count = 3
    #   enable_node_public_ip          = true
    # }
  }
  addons = {
    oms_agent = true
  }
  system_assigned_managed_identity = false
  network_profile = {
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    network_plugin     = "kubenet"       # (Required) Currently supported values are azure and kubenet.
    network_policy     = "calico"        #  (Optional) This field can only be set when network_plugin is set to azure. Currently supported values are calico and azure. 
    dns_service_ip     = "10.8.0.10"     # required when network_plugin is set to azure. It is IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)
    docker_bridge_cidr = "172.17.0.1/16" # Required when network_plugin is set to azure. IP address (in CIDR notation) used as the Docker bridge IP address on nodes. 
    service_cidr       = "10.8.0.0/16"   # Required when network_plugin is set to azure. It is the Network Range used by the Kubernetes service. 
  }

#-------------------------------
# Module: Ansible Provisioner
#-------------------------------

  arguments = ["-vv"]
  envs      = ["GRAFANA_GENERATED_PASSWORD=cGFzc3dvcmQK", "backup_resource_group=final-dev-resgp"] 
  playbook  = "ansible/kubectl.yaml"
  dry_run   = false
#-------------------------------
# Module: SQL
#-------------------------------

  sql_location = null
  sql_name_suffix = ""
  sql_server_version = "12.0"
  sql_allowed_cidr_list = ["0.0.0.0/32"]
  sql_extra_tags = {}
  sql_server_extra_tags = {}
  # sql_elastic_pool_extra_tags = {}
  sql_databases_extra_tags = {}
  sql_server_custom_name = ""
  # sql_elastic_pool_custom_name = ""
  sql_administrator_login = "necuser" 
  sql_administrator_password = "Nec@1234"
  # sql_elastic_pool_max_size = "50"   # Dependent on sku tier
  # sql_sku = {
  #     name = "GP_Gen5"
  #     tier   = "GeneralPurpose"
  #     family = "Gen5"
  #     capacity = "6"
  #   }
  # sql_zone_redundant = false
  # sql_database_min_dtu_capacity = "0"
  # sql_database_max_dtu_capacity = "4" # The DTU max per database must be less than (5) for service tier 'Basic'
  sql_nb_database = 2
  sql_databases_collation = "SQL_LATIN1_GENERAL_CP1_CI_AS"
  # sql_enable_logging = true
  # sql_logs_storage_retention = 30
  # sql_log_analytics_workspace_sku = "PerGB2018"
  sql_enable_advanced_data_security = true
  sql_enable_advanced_data_security_admin_emails = true
  sql_advanced_data_security_additional_emails = ["test@nec.com"]
  sql_create_databases_users = true
  sql_daily_backup_retention = 35
  sql_weekly_backup_retention = 0
  sql_monthly_backup_retention = 3
  sql_yearly_backup_retention = 0
  sql_yearly_backup_time = 52
  sql_requested_service_objective_name = "GP_Gen5_2"
