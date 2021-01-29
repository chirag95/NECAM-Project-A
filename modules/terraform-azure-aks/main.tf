locals {
  prefix = format("%s-%s", var.stack, var.environment)
  default_tags = {
    env   = var.environment
    stack = var.stack
  }

}
data "azurerm_resource_group" "aks" {
  name = var.resource_group_name
}

data "azuread_service_principal" "aks_principal" {
  count          = var.system_assigned_managed_identity == false ? 1 : 0
  application_id = var.client_id != "" && var.client_secret != "" ? var.client_id : module.service_principal[0].client_id #var.aks_service_principal_client_id
}

# Create an SSH key
module "ssh_key" {
  count  = var.use_existing_ssh_key == false ? 1 : 0
  source = "../terraform-azure-ssh-key"
}

module "service_principal" {
  count            = (var.client_id == "" || var.client_secret == "") && var.system_assigned_managed_identity == false ? 1 : 0
  source           = "../terraform-azure-service-principal"
  application_name = "${local.prefix}-aks"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.prefix}-aks"
  location            = var.location 
  resource_group_name = data.azurerm_resource_group.aks.name
  dns_prefix          = local.prefix
  node_resource_group = var.node_resource_group

  kubernetes_version              = var.kubernetes_version
  private_cluster_enabled         = var.private_cluster
  sku_tier                        = var.sku_tier
  api_server_authorized_ip_ranges = var.api_auth_ips #Private cluster cannot be enabled with AuthorizedIPRanges.

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = var.use_existing_ssh_key == true ? file(var.ssh_key) : module.ssh_key[0].admin_ssh_key_public
    }
  }
  dynamic windows_profile {
    for_each = var.network_profile.network_plugin == "azure" ? [{}] : []
    content{
      admin_password = var.admin_password
      admin_username = var.admin_username
    }
  }
  default_node_pool {
    name                 = substr(var.default_node_pool.name, 0, 12)
    orchestrator_version = var.kubernetes_version
    node_count           = var.default_node_pool.node_count
    vm_size              = var.default_node_pool.vm_size
    type                 = var.default_node_pool.type
    availability_zones   = var.default_node_pool.zones
    max_pods             = var.default_node_pool.max_pods
    os_disk_size_gb      = var.default_node_pool.os_disk_size_gb
    vnet_subnet_id       = var.vnet_subnet_id
    node_labels          = var.default_node_pool.labels
    node_taints          = var.default_node_pool.taints
    enable_auto_scaling  = var.default_node_pool.cluster_auto_scaling
    min_count            = var.default_node_pool.cluster_auto_scaling_min_count
    max_count            = var.default_node_pool.cluster_auto_scaling_max_count
    # enable_node_public_ip = var.default_node_pool.enable_node_public_ip
  }
  dynamic service_principal {
    for_each = (var.client_id != "" && var.client_secret != "") && var.system_assigned_managed_identity == false ? ["service_principal"] : []
    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }

  dynamic service_principal {
    for_each = (var.client_id == "" || var.client_secret == "") && var.system_assigned_managed_identity == false ? ["new_service_principal"] : []
    content {
      client_id     = module.service_principal[0].client_id
      client_secret = module.service_principal[0].client_secret
    }
  }

  dynamic identity {
    for_each = var.system_assigned_managed_identity == true ? ["identity"] : []
    content {
      type = "SystemAssigned"
    }
  }

  addon_profile {
    kube_dashboard {
      enabled = false  #The addon "kubeDashboard" is not supported for a Kubernetes Cluster located in "AzureUSGovernmentCloud"
    }
  }

  role_based_access_control {
    enabled = var.enable_role_based_access_control

    dynamic azure_active_directory {
      for_each = var.enable_role_based_access_control && var.rbac_aad_managed == true ? ["rbac"] : []
      content {
        managed                = true
        admin_group_object_ids = var.rbac_aad_admin_group_object_ids
      }
    }

    dynamic azure_active_directory {
      for_each = var.enable_role_based_access_control && var.rbac_aad_managed ==false? ["rbac"] : []
      content {
        managed           = false
        client_app_id     = var.rbac_aad_client_app_id
        server_app_id     = var.rbac_aad_server_app_id
        server_app_secret = var.rbac_aad_server_app_secret
      }
    }
  }

  network_profile {
    load_balancer_sku  = var.network_profile.load_balancer_sku
    outbound_type      = var.network_profile.outbound_type
    network_plugin     = var.network_profile.network_plugin
    network_policy     = var.network_profile.network_policy
    dns_service_ip     = var.network_profile.dns_service_ip
    docker_bridge_cidr = var.network_profile.docker_bridge_cidr
    service_cidr       = var.network_profile.service_cidr
  }

  tags = merge(local.default_tags, var.tags)
}

resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  for_each = var.additional_node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = each.value.node_os == "Windows" ? substr(each.key, 0, 6) : substr(each.key, 0, 12)
  orchestrator_version  = var.kubernetes_version
  node_count            = each.value.node_count
  vm_size               = each.value.vm_size
  availability_zones    = each.value.zones
  max_pods              = each.value.max_pods
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_type               = each.value.node_os
  vnet_subnet_id        = var.vnet_subnet_id
  node_labels           = each.value.labels
  node_taints           = each.value.taints
  enable_auto_scaling   = each.value.cluster_auto_scaling
  min_count             = each.value.cluster_auto_scaling_min_count
  max_count             = each.value.cluster_auto_scaling_max_count
  # enable_node_public_ip = each.value.enable_node_public_ip
}

module "acr" {
  source              = "../terraform-azure-acr"
  name                = format("%sacr", replace(local.prefix, "/[[:^alnum:]]/", ""))
  resource_group_name = data.azurerm_resource_group.aks.name
  location            = var.location 
  sku                 = "Standard"
  admin_enabled       = false
}