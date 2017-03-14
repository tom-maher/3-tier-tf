variable resource_group_name                        { }
variable location                                   { }

resource "azurerm_resource_group" "rg" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"
}

output "id" {
  value = "${azurerm_resource_group.rg.id}"
}

output "name" {
  value = "${azurerm_resource_group.rg.name}"
}
