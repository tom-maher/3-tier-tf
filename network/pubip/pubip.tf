variable "location"                           { }
variable "resource_group_name"                { }
variable "pubip_jumplb_name"                  { }
variable "pubip_appgwlb_name"                 { }
variable "pubip_allocation"                   { }

resource "azurerm_public_ip" "pubip_jumplb" {
    name = "${var.pubip_jumplb_name}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    public_ip_address_allocation = "${var.pubip_allocation}"
    domain_name_label = "jump-dlmc-tf"
}

resource "azurerm_public_ip" "pubip_appgwlb" {
    name = "${var.pubip_appgwlb_name}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    public_ip_address_allocation = "${var.pubip_allocation}"
    domain_name_label ="appgw-dlmc-tf"
}

output "pubip_jumplb_id" {
  value = "${azurerm_public_ip.pubip_jumplb.id}"
}
output "pubip_jumplb_name" {
  value = "${azurerm_public_ip.pubip_jumplb.name}"
}

output "pubip_appgwlb_id" {
  value = "${azurerm_public_ip.pubip_appgwlb.id}"
}
output "pubip_appgwlb_name" {
  value = "${azurerm_public_ip.pubip_appgwlb.name}"
}
