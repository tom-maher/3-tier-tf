variable "location"                               { }
variable "resource_group_name"                    { }
variable "virtual_network_name"                   { }
variable "subnet_app_name"                        { }
variable "subnet_app_prefix"                      { }
variable "subnet_app_nsg"                         { }
variable "subnet_dmz_name"                        { }
variable "subnet_dmz_prefix"                      { }
variable "subnet_dmz_nsg"                         { }
variable "subnet_db_name"                         { }
variable "subnet_db_prefix"                       { }
variable "subnet_db_nsg"                          { }
variable "subnet_maint_name"                      { }
variable "subnet_maint_prefix"                    { }
variable "subnet_maint_nsg"                       { }
variable "subnet_gw_name"                         { }
variable "subnet_gw_prefix"                       { }
variable "subnet_gw_nsg"                          { }

resource "azurerm_subnet" "subnet_app"  {
  name  = "${var.subnet_app_name}"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix = "${var.subnet_app_prefix}"
  network_security_group_id = "${var.subnet_app_nsg}"
}

resource "azurerm_subnet" "subnet_dmz"  {
  name  = "${var.subnet_dmz_name}"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix = "${var.subnet_dmz_prefix}"
  network_security_group_id = "${var.subnet_dmz_nsg}"
}

resource "azurerm_subnet" "subnet_db"  {
  name  = "${var.subnet_db_name}"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix = "${var.subnet_db_prefix}"
  network_security_group_id = "${var.subnet_db_nsg}"
}

resource "azurerm_subnet" "subnet_maint"  {
  name  = "${var.subnet_maint_name}"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix = "${var.subnet_maint_prefix}"
  network_security_group_id = "${var.subnet_maint_nsg}"
}

resource "azurerm_subnet" "subnet_gw"  {
  name  = "${var.subnet_gw_name}"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix = "${var.subnet_gw_prefix}"
  network_security_group_id = "${var.subnet_gw_nsg}"
}

output "subnet_app_id" {
  value = "${azurerm_subnet.subnet_app.id}"
}

output "subnet_dmz_id" {
  value = "${azurerm_subnet.subnet_dmz.id}"
}

output "subnet_db_id" {
  value = "${azurerm_subnet.subnet_db.id}"
}

output "subnet_maint_id" {
  value = "${azurerm_subnet.subnet_maint.id}"
}

output "gw_id" {
  value = "${azurerm_subnet.subnet_gw.id}"
}
