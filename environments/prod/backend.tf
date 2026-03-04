terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateprodXXXXX"       # เปลี่ยนให้ unique
    container_name       = "tfstate"
    key                  = "prod/aks.terraform.tfstate"
    use_oidc             = true                      # ใช้ Workload Identity ใน CI/CD
  }
}