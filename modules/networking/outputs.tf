output "resource_group_name" { value = azurerm_resource_group.rg.name }
output "resource_group_id"   { value = azurerm_resource_group.rg.id }
output "vnet_id"             { value = azurerm_virtual_network.vnet.id }
output "aks_subnet_id"       { value = azurerm_subnet.aks_subnet.id }
output "appgw_id"            { value = azurerm_application_gateway.appgw.id }
output "appgw_pip"           { value = azurerm_public_ip.appgw_pip.ip_address }