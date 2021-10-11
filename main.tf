terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=2.80.0"
      # version = "~>2.80.0" For production grade, through this only last number will get update
    }
  }
}
provider "azurerm" {
features{}
}

variable "prefix"{
  default = "rahul"
}

data "azurerm_resource_group" "${var.prefix}-rg" {
  name = "Devops_Kochi"
}

resource "azurerm_virtual_network" "rahulvnet" {
  name                = "rahulvnet-1"
  address_space       = ["10.0.0.0/16"] #this is a list item
  location            = data.azurerm_resource_group.rahul-rg.location
  resource_group_name = data.azurerm_resource_group.rahul-rg.name
  tags                ={ 
                        "Name" = "rahulvnet-1"
                        }
}

resource "azurerm_subnet" "rahulsubnet" {
  name                 = "rahulsubnet-1"
  resource_group_name  = data.azurerm_resource_group.rahul-rg.name
  virtual_network_name = azurerm_virtual_network.rahulvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "rahul-nic" {
  name                = "rahul-nic"
  location            = data.azurerm_resource_group.rahul-rg.location
  resource_group_name = data.azurerm_resource_group.rahul-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rahulsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "rahulvm" {
  name                = "rahul-machine"
  resource_group_name = data.azurerm_resource_group.rahul-rg.name
  location            = data.azurerm_resource_group.rahul-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.rahul-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
