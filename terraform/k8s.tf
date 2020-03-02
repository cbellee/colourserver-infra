resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location
}

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "wks" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = var.log_analytics_workspace_location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "wks" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.wks.location
    resource_group_name   = azurerm_resource_group.rg.name
    workspace_resource_id = azurerm_log_analytics_workspace.wks.id
    workspace_name        = azurerm_log_analytics_workspace.wks.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Development"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "aks-subnet-0"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefix       = "10.0.1.0/24"
  virtual_network_name = azurerm_virtual_network.vnet.name
}

/* resource "azurerm_kubernetes_cluster_node_pool" "nodepool" {
  name                  = "default"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = var.agent_vm_size
  node_count            = var.agent_count
  vnet_subnet_id        = azurerm_subnet.subnet.id
} */

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    dns_prefix          = var.dns_prefix
    kubernetes_version  = var.aks_version

    network_profile {
      network_plugin     = "azure"
      load_balancer_sku = "standard"
    }

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
      name = "default"
      vm_size = var.agent_vm_size
      node_count = var.agent_count
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    role_based_access_control {
        enabled = true
    }

    addon_profile {
        oms_agent {
          enabled                    = true
          log_analytics_workspace_id = azurerm_log_analytics_workspace.wks.id
        }
    }

    tags = {
        Environment = "Development"
    }
}