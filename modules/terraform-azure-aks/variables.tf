variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name to be imported"
  type        = string
}

variable "location" {
  description = "Region is which resources will be created."
  type = string
  default = null
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "client_id" {
  description = "(Optional) The Client ID (appId) for the Service Principal used for the AKS deployment"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "(Optional) The Client Secret (password) for the Service Principal used for the AKS deployment"
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "The username of the local administrator to be created on the Kubernetes cluster"
  type        = string
  default     = "azureuser"
}

variable "agents_size" {
  description = "The default virtual machine size for the Kubernetes agents"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "ssh_key" {
  description = "Path to the public key to be used for ssh access to the VM.  Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub."
  type        = string
  default     = ""
}

variable "use_existing_ssh_key" {
  description = "Generates a secure private key and encodes it as PEM."
  default     = false
}

variable "admin_password" {
  description = "The admin password to be used on the Windows VMs."
  type        = string
  default     = "Nci-automation@123"
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the Virtual Network resources"
  default     = {}
}

variable "vnet_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid"
  type        = string
  default     = "Free"
}

variable "enable_role_based_access_control" {
  description = "Enable Role Based Access Control."
  type        = bool
  default     = true
}

variable "rbac_aad_managed" {
  description = "Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration."
  type        = bool
  default     = false
}

variable "rbac_aad_admin_group_object_ids" {
  description = "Object ID of groups with admin access."
  type        = list(string)
  default     = null
}

variable "rbac_aad_client_app_id" {
  description = "The Client ID of an Azure Active Directory Application."
  type        = string
  default     = null
}

variable "rbac_aad_server_app_id" {
  description = "The Server ID of an Azure Active Directory Application. Same as APP_ID"
  type        = string
  default     = null
}

variable "rbac_aad_server_app_secret" {
  description = "The Server Secret of an Azure Active Directory Application. Same as APP_KEY or client_secret"
  type        = string
  default     = null
}

variable "default_node_pool" {
  description = "The object to configure the default node pool with number of worker nodes, worker node VM size and Availability Zones."
  type = object({
    name                           = string
    node_count                     = number
    vm_size                        = string
    type                           = string
    zones                          = list(string)
    max_pods                       = number
    os_disk_size_gb                = number
    labels                         = map(string)
    taints                         = list(string)
    cluster_auto_scaling           = bool
    cluster_auto_scaling_min_count = number
    cluster_auto_scaling_max_count = number
    enable_node_public_ip          = bool
  })
  default = {
    name                           = "nodepool"
    node_count                     = 2
    vm_size                        = "Standard_B2s"
    type                           = "VirtualMachineScaleSets" # or AvailabilitySets
    zones                          = null
    max_pods                       = 250
    os_disk_size_gb                = 50
    labels                         = null
    taints                         = null
    cluster_auto_scaling           = true
    cluster_auto_scaling_min_count = 1
    cluster_auto_scaling_max_count = 3
    enable_node_public_ip          = true
  }
}

variable "additional_node_pools" {
  description = "The map object to configure one or several additional node pools with number of worker nodes, worker node VM size and Availability Zones."
  type = map(object({
    node_count                     = number
    vm_size                        = string
    zones                          = list(string)
    max_pods                       = number
    os_disk_size_gb                = number
    labels                         = map(string)
    taints                         = list(string)
    node_os                        = string
    cluster_auto_scaling           = bool
    cluster_auto_scaling_min_count = number
    cluster_auto_scaling_max_count = number
    enable_node_public_ip          = bool
  }))
  default = {
    "pool2" = {
      node_count                     = 2
      vm_size                        = "Standard_B2s"
      zones                          = null #["1", "2", "3"]
      max_pods                       = 250
      os_disk_size_gb                = 50
      labels                         = null
      taints                         = null
      node_os                        = "Linux"     # Windows agent pools can only be added to AKS clusters using Azure-CNI.
      cluster_auto_scaling           = true
      cluster_auto_scaling_min_count = 1
      cluster_auto_scaling_max_count = 3
      enable_node_public_ip          = true
    }
  }
}

variable "addons" {
  description = "Defines which addons will be activated."
  type = object({
    oms_agent                = bool
  })
  default = {
    oms_agent                = true
  }
}

variable "api_auth_ips" {
  description = "Whitelist of IP addresses that are allowed to access the AKS Master Control Plane API. Private cluster cannot be enabled with AuthorizedIPRanges."
  type        = list(string)
  default = null
}

variable "private_cluster" {
  description = "Deploy an AKS cluster without a public accessible API endpoint."
  type        = bool
  default = true
}

variable "system_assigned_managed_identity" {
  description = " Use system assigned managed identity instead of service principal"
  type = bool
  default = false
}

variable "network_profile" {
  description = "Network profile to be used. If network_profile is not defined, kubenet profile will be used by default."
  type = object({
    load_balancer_sku  = string
    outbound_type      = string
    network_plugin     = string    
    network_policy     = string
    dns_service_ip     = string
    docker_bridge_cidr = string
    service_cidr       = string
  })
  default =  {   
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    network_plugin     = "azure"    # (Required) Currently supported values are azure and kubenet.
    network_policy     = "calico"   #  (Optional) This field can only be set when network_plugin is set to azure. Currently supported values are calico and azure. 
    dns_service_ip     = "10.8.0.10" # required when network_plugin is set to azure. It is IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)
    docker_bridge_cidr = "172.17.0.1/16" # Required when network_plugin is set to azure. IP address (in CIDR notation) used as the Docker bridge IP address on nodes. 
    service_cidr       = "10.8.0.0/16" # Required when network_plugin is set to azure. It is the Network Range used by the Kubernetes service. 
  }
}

variable "node_resource_group" {
  description = "Name of autogenerated Resource Group which will contain the resources for this Managed Kubernetes Cluster."
  type = string
  default = null
}