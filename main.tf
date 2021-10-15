terraform {
  backend "azurerm" {
    resource_group_name  = "Devops_Kochi"
    storage_account_name = "rahul1storageaccount"
    container_name       = "blobcontainer"
    key                  = "terraform.tfstate"
  }
}


provider "azurerm" {
  version = "~>2.0"
  skip_provider_registration = true
  features {}
}


data "azurerm_resource_group" "rahulrg" {
  name = "Devops_Kochi"
}

resource "azurerm_app_service_plan" "rahulappserviceplan" {
  name                = "rahul-appserviceplan"
  location            = azurerm_resource_group.rahulrg.location
  resource_group_name = azurerm_resource_group.rahulrg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_app_service" "rahulappservice" {
  name                = "rahul-app-service"
  location            = azurerm_resource_group.rahulrg.location
  resource_group_name = azurerm_resource_group.rahulrg.name
  app_service_plan_id = azurerm_app_service_plan.rahulappserviceplan.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }


}



