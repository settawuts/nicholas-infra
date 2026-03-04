output "cluster_id"                  { value = azurerm_kubernetes_cluster.aks.id }
output "cluster_name"                { value = azurerm_kubernetes_cluster.aks.name }
output "kube_config"                 { value = azurerm_kubernetes_cluster.aks.kube_config_raw; sensitive = true }
output "identity_object_id"          { value = azurerm_user_assigned_identity.aks.principal_id }
output "acr_login_server"            { value = azurerm_container_registry.acr.login_server }
output "oidc_issuer_url"             { value = azurerm_kubernetes_cluster.aks.oidc_issuer_url }