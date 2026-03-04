variable "prefix"                  { type = string }
variable "environment"             { type = string }
variable "location"                { type = string }
variable "resource_group_name"     { type = string }
variable "allowed_subnet_ids"      { type = list(string) }
variable "allowed_ip_ranges"       { type = list(string) }
variable "aks_identity_object_id"  { type = string }
variable "tags"                    { type = map(string) }