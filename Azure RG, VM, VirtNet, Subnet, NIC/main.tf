variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "location" {
 default ="<%=customOptions.location%>"
}
variable "resource_group_name" {
 default = "<%=customOptions.resource_group_name%>"
}
variable "vnet_name" {
 default ="<%=customOptions.vnet_name%>"
}
variable "vnet_address_space" {
 type = list(string)
}
variable "subnet_name" {}
variable "subnet_address_prefixes" {
 type = list(string)
}
variable "vm_name" {}
variable "vm_size" {}
variable "vm_user" {}
variable "vm_password" {}
terraform {
 required_providers {
  azurerm = { 
   source = "hashicorp/azurerm"
   version = "3.0.0"
  }
 }
}
provider "azurerm" {
 features {}
 subscription_id =  var.subscription_id
 client_id =        var.client_id
 client_secret =    var.client_secret
 tenant_id =        var.tenant_id
}
resource "azurerm_resource_group" "rg" {
 name = var.resource_group_name
 location = var.location
}
resource "azurerm_virtual_network" "vnet" {
 name =                 var.vnet_name
 location =             azurerm_resource_group.rg.location
 resource_group_name =  azurerm_resource_group.rg.name
 address_space =        var.vnet_address_space
}
resource "azurerm_subnet" "snet" {
 name =                     var.subnet_name
 resource_group_name =      azurerm_resource_group.rg.name
 virtual_network_name =     azurerm_virtual_network.vnet.name
 address_prefixes =        var.subnet_address_prefixes
}
resource "azurerm_network_interface" "nic" {
 name=                  "nic-${var.vm_name}"
 location =             azurerm_resource_group.rg.location
 resource_group_name =  azurerm_resource_group.rg.name
 ip_configuration {
  name = "internal"
  subnet_id = azurerm_subnet.snet.id
  private_ip_address_allocation = "Dynamic"
 }
}
resource "azurerm_linux_virtual_machine" "vm" {
    name = var.vm_name
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = var.vm_size
    admin_username = var.vm_user
    admin_password = var.vm_password
    disable_password_authentication = false
    network_interface_jds= [
     azurerm_network_interface.nic.id
    ]
    os_disk {
     caching = "ReadWrite"
     storage_account_type = "Standard_LRS"
    }
    source_image_reference {
     publisher = "Canonical"
     offer ="UbuntuServer"
     sku = "18.04-LTS"
     version = "latest"
    }
   }