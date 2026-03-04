resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "alert_group" {
  name                = "${var.prefix}-alert-group"
  resource_group_name = var.resource_group_name
  short_name          = "aksalerts"

  email_receiver {
    name          = "devops-team"
    email_address = var.alert_email
  }
}

# Alert: Node CPU > 80%
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "${var.prefix}-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.alert_group.id
  }
}