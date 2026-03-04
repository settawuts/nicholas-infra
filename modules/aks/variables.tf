variable "prefix"                          { type = string }
variable "environment"                     { type = string }
variable "location"                        { type = string }
variable "resource_group_name"             { type = string }
variable "dns_prefix"                      { type = string }
variable "kubernetes_version"              { type = string }
variable "aks_subnet_id"                   { type = string }
variable "application_gateway_id"          { type = string }
variable "log_analytics_workspace_id"      { type = string }
variable "admin_group_object_ids"          { type = list(string) }
variable "api_server_authorized_ip_ranges" { type = list(string) }
variable "acr_geo_replication_location"    { type = string; default = "southeastasia" }
variable "service_cidr"                    { type = string; default = "10.100.0.0/16" }
variable "dns_service_ip"                  { type = string; default = "10.100.0.10" }

variable "system_node_vm_size"    { type = string; default = "Standard_DS3_v2" }
variable "system_node_min_count"  { type = number; default = 3 }
variable "system_node_max_count"  { type = number; default = 5 }

variable "app_node_vm_size"       { type = string; default = "Standard_D4s_v3" }
variable "app_node_min_count"     { type = number; default = 3 }
variable "app_node_max_count"     { type = number; default = 20 }

variable "spot_node_vm_size"      { type = string; default = "Standard_D4s_v3" }
variable "spot_node_max_count"    { type = number; default = 10 }

variable "tags"                   { type = map(string) }