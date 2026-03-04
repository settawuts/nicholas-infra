variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "prefix"              { type = string }
variable "vnet_address_space"  { type = list(string) }
variable "aks_subnet_cidr"     { type = list(string) }
variable "appgw_subnet_cidr"   { type = list(string) }
variable "tags"                { type = map(string) }