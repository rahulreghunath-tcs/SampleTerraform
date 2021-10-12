
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
variable "prefix"{
  default = "rahul"
}

data "azurerm_resource_group" "rahulrg" {
  name = "Devops_Kochi"
}

resource "azurerm_virtual_network" "rahulvnet" {
  name                = "rahulvnet-1"
  address_space       = ["10.0.0.0/16"] #this is a list item
  location            = data.azurerm_resource_group.rahulrg.location
  resource_group_name = data.azurerm_resource_group.rahulrg.name
  tags                ={ 
                        "env" = "rahuldev"
                        }
}

resource "azurerm_subnet" "rahulsubnet" {
  name                 = "rahulsubnet-1"
  resource_group_name  = data.azurerm_resource_group.rahulrg.name
  virtual_network_name = azurerm_virtual_network.rahulvnet.name
  address_prefixes     = ["10.0.2.0/24"]
 
}
resource "azurerm_public_ip" "rahulpublicip" {
  name                = "rahulPublicIp1"
  resource_group_name = data.azurerm_resource_group.rahulrg.name
  location            = data.azurerm_resource_group.rahulrg.location
  allocation_method   = "Static"

  tags = {
    env = "dev"
  }
}

resource "azurerm_network_interface" "rahul-nic" {
  name                = "rahul-nic"
  location            = data.azurerm_resource_group.rahulrg.location
  resource_group_name = data.azurerm_resource_group.rahulrg.name
   tags                ={ 
                        "env" = "rahuldev"
                        }

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rahulsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         =azurerm_public_ip.rahulpublicip.id
  }
}

resource "azurerm_windows_virtual_machine" "rahulvm" {
  name                = "rahul-machine"
  resource_group_name = data.azurerm_resource_group.rahulrg.name
  location            = data.azurerm_resource_group.rahulrg.location
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
