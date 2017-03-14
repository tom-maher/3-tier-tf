variable "location"                           { }
variable "resource_group_name"                { }
variable "virtual_network_name"               { }
variable "vnet_address_space"                 { }

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${split(",",var.vnet_address_space)}"]
}

output "id" {
  value = "${azurerm_virtual_network.vnet.id}"
}

output "name" {
  value = "${azurerm_virtual_network.vnet.name}"
}
