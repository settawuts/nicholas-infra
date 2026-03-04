variable "prefix"               { type = string }
variable "environment"          { type = string }
variable "location"             { type = string }
variable "resource_group_name"  { type = string }
variable "log_retention_days"   { type = number; default = 90 }
variable "alert_email"          { type = string }
variable "aks_cluster_id"       { type = string; default = "" }
variable "tags"                 { type = map(string) }