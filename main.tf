provider "azurerm" {
  version = "~>2.0"
  skip_provider_registration = true
  features {}
}
resource "azurerm_virtual_network" "rahulvnet" {
  name = "rahul-vnet"
  address_space = ["10.0.0.0/16"]
  location = "northeurope"
  resource_group_name = "Devops_Kochi"
}
