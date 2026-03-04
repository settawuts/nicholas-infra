# ── General ────────────────────────────────────────────────────────────
prefix      = "myapp-prod"
environment = "prod"
location    = "southeastasia"   # Singapore - ใกล้ไทย

# ── Networking ─────────────────────────────────────────────────────────
vnet_address_space = ["10.0.0.0/8"]
aks_subnet_cidr    = ["10.1.0.0/16"]
appgw_subnet_cidr  = ["10.2.0.0/24"]

# ── AKS ────────────────────────────────────────────────────────────────
kubernetes_version              = "1.31.0"
admin_group_object_ids          = ["<YOUR-AAD-GROUP-OBJECT-ID>"]
api_server_authorized_ip_ranges = ["<YOUR-OFFICE-IP>/32", "<VPN-IP>/32"]

# ── Monitoring ─────────────────────────────────────────────────────────
alert_email = "devops@yourcompany.com"

# ── Key Vault ──────────────────────────────────────────────────────────
allowed_ip_ranges = ["<YOUR-OFFICE-IP>/32"]

# ── Tags ───────────────────────────────────────────────────────────────
tags = {
  environment = "prod"
  project     = "myapp"
  owner       = "devops-team"
  cost-center = "engineering"
  managed-by  = "terraform"
}