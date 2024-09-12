resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  tags                = {
    Environment = "Demo"
  }

  default_node_pool {
    name       = "demopool"
    vm_size    = "Standard_D2ps_v5"
    node_count = var.node_count
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_monitor_workspace" "azmonwkspc" {
  name                = "azmon-workspace"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_monitor_data_collection_endpoint" "mon_data_coll_endpoint" {
  name                = "mon-data-coll-endpoint"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "Linux"
}

resource "azurerm_monitor_data_collection_rule" "mon_data_coll_rule" {
  name                        = "mon-data-coll-rule"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.mon_data_coll_endpoint.id

  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.azmonwkspc.id
      name               = azurerm_monitor_workspace.azmonwkspc.name
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = [azurerm_monitor_workspace.azmonwkspc.name]
  }
}

# associate to a Data Collection Rule
resource "azurerm_monitor_data_collection_rule_association" "mon_data_coll_rule_to_aks" {
  name                    = "data-coll-rule-${azurerm_kubernetes_cluster.k8s.name}"
  target_resource_id      = azurerm_kubernetes_cluster.k8s.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.mon_data_coll_rule.id
}

# associate to a Data Collection Endpoint
resource "azurerm_monitor_data_collection_rule_association" "mon_data_coll_endpoint_to_aks" {
  target_resource_id          = azurerm_kubernetes_cluster.k8s.id
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.mon_data_coll_endpoint.id
}

resource "azurerm_dashboard_grafana" "az_managed_grafana" {
  name                     = "az-managed-grafana"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  grafana_major_version    = 10

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.azmonwkspc.id
  }
}

resource "azurerm_role_assignment" "mon_role_assignment_self" {
  scope                = azurerm_monitor_workspace.azmonwkspc.id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "mon_role_assignment_grafana" {
  scope                = azurerm_monitor_workspace.azmonwkspc.id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.az_managed_grafana.identity[0].principal_id
}

resource "azurerm_role_assignment" "grafana_role_assignment_self" {
  scope                = azurerm_dashboard_grafana.az_managed_grafana.id
  role_definition_name = "Grafana Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}