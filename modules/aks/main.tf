# ── Container Registry ────────────────────────────────────────────────
resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.prefix, "-", "")}acr${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = false

  # Geo-replication สำหรับ Prod
  georeplications {
    location                = var.acr_geo_replication_location
    zone_redundancy_enabled = true
  }

  tags = var.tags
}

# ── User-Assigned Managed Identity ───────────────────────────────────
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.prefix}-aks-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# ── Role: AKS → ACR (AcrPull) ────────────────────────────────────────
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# ── Role: AKS → Subnet (Network Contributor) ─────────────────────────
resource "azurerm_role_assignment" "aks_network" {
  scope                = var.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# ── AKS Cluster ───────────────────────────────────────────────────────
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # ── Identity ──────────────────────────────────────────────────────
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # ── System Node Pool ──────────────────────────────────────────────
  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    enable_auto_scaling          = true
    min_count                    = var.system_node_min_count
    max_count                    = var.system_node_max_count
    os_disk_size_gb              = 128
    os_disk_type                 = "Managed"
    type                         = "VirtualMachineScaleSets"
    zones                        = ["1", "2", "3"]
    vnet_subnet_id               = var.aks_subnet_id
    only_critical_addons_enabled = true   # System pool: เฉพาะ system workloads

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }

    upgrade_settings {
      max_surge = "33%"
    }
  }

  # ── Network Profile ───────────────────────────────────────────────
  network_profile {
    network_plugin      = "azure"
    network_policy      = "azure"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
  }

  # ── Azure AD RBAC ─────────────────────────────────────────────────
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  # ── Workload Identity + OIDC ──────────────────────────────────────
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # ── Security ──────────────────────────────────────────────────────
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

  # ── Add-ons ───────────────────────────────────────────────────────
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  ingress_application_gateway {
    gateway_id = var.application_gateway_id
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  azure_policy_enabled             = true
  http_application_routing_enabled = false

  # ── Maintenance Window ────────────────────────────────────────────
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [2, 4]
    }
  }

  # ── Auto-upgrade ─────────────────────────────────────────────────
  automatic_channel_upgrade = "patch"

  node_os_channel_upgrade = "NodeImage"

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version,
    ]
  }
}

# ── User Node Pool: Application Workloads ────────────────────────────
resource "azurerm_kubernetes_cluster_node_pool" "app" {
  name                  = "app"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.app_node_vm_size
  enable_auto_scaling   = true
  min_count             = var.app_node_min_count
  max_count             = var.app_node_max_count
  os_disk_size_gb       = 128
  vnet_subnet_id        = var.aks_subnet_id
  zones                 = ["1", "2", "3"]

  node_labels = {
    "nodepool-type" = "app"
    "environment"   = var.environment
  }

  upgrade_settings {
    max_surge = "33%"
  }
}

# ── Spot Node Pool: Cost Optimization ────────────────────────────────
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.spot_node_vm_size
  enable_auto_scaling   = true
  min_count             = 0
  max_count             = var.spot_node_max_count
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = -1
  vnet_subnet_id        = var.aks_subnet_id

  node_labels = {
    "nodepool-type"                          = "spot"
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }

  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]
}

# ── Diagnostic Settings ───────────────────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "${var.prefix}-aks-diag"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "kube-apiserver" }
  enabled_log { category = "kube-controller-manager" }
  enabled_log { category = "kube-scheduler" }
  enabled_log { category = "kube-audit" }
  enabled_log { category = "kube-audit-admin" }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}