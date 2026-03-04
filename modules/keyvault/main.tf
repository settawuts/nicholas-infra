data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-kv-${var.environment}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"

  # Prod: เปิด soft-delete และ purge protection
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true

  # Network ACL - อนุญาตเฉพาะ VNet
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.allowed_subnet_ids
    ip_rules                   = var.allowed_ip_ranges
  }

  tags = var.tags
}

# Access Policy สำหรับ AKS
resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.aks_identity_object_id

  secret_permissions = ["Get", "List"]
  key_permissions    = ["Get", "List", "UnwrapKey", "WrapKey"]
}