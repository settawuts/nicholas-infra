# ── Networking ─────────────────────────────────────────────────────────
module "networking" {
  source = "../../modules/networking"

  resource_group_name = "${var.prefix}-network-rg"
  location            = var.location
  prefix              = var.prefix
  vnet_address_space  = var.vnet_address_space
  aks_subnet_cidr     = var.aks_subnet_cidr
  appgw_subnet_cidr   = var.appgw_subnet_cidr
  tags                = var.tags
}

# ── Monitoring (สร้างก่อน AKS) ─────────────────────────────────────────
module "monitoring" {
  source = "../../modules/monitoring"

  prefix              = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  log_retention_days  = 90
  alert_email         = var.alert_email
  tags                = var.tags

  depends_on = [module.networking]
}

# ── AKS Cluster ────────────────────────────────────────────────────────
module "aks" {
  source = "../../modules/aks"

  prefix                          = var.prefix
  environment                     = var.environment
  location                        = var.location
  resource_group_name             = module.networking.resource_group_name
  dns_prefix                      = var.prefix
  kubernetes_version              = var.kubernetes_version
  aks_subnet_id                   = module.networking.aks_subnet_id
  application_gateway_id          = module.networking.appgw_id
  log_analytics_workspace_id      = module.monitoring.log_analytics_workspace_id
  admin_group_object_ids          = var.admin_group_object_ids
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  tags                            = var.tags

  depends_on = [module.networking, module.monitoring]
}

# ── Key Vault ──────────────────────────────────────────────────────────
module "keyvault" {
  source = "../../modules/keyvault"

  prefix                 = var.prefix
  environment            = var.environment
  location               = var.location
  resource_group_name    = module.networking.resource_group_name
  allowed_subnet_ids     = [module.networking.aks_subnet_id]
  allowed_ip_ranges      = var.allowed_ip_ranges
  aks_identity_object_id = module.aks.identity_object_id
  tags                   = var.tags

  depends_on = [module.aks]
}