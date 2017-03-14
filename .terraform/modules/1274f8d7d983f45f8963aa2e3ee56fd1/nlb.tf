variable "location"                               { }
variable "resource_group_name"                    { }
variable "nlb_jumplb_name"                        { }
variable "pubip_jumplb_name"                      { }
variable "pubip_appgwlb_name"                     { }
variable "pubip_allocation"                       { }

module "pubip" {
  source = "../pubip"

  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  pubip_jumplb_name = "${var.pubip_jumplb_name}"
  pubip_appgwlb_name = "${var.pubip_appgwlb_name}"
  pubip_allocation = "${var.pubip_allocation}"
  }

resource "azurerm_lb" "nlb_jumplb" {
    name = "${var.nlb_jumplb_name}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    frontend_ip_configuration {
      name = "${module.pubip.pubip_jumplb_name}"
      public_ip_address_id ="${module.pubip.pubip_jumplb_id}"
    }
}

resource "azurerm_lb_nat_rule" "nlb_jumplb_nat" {
  #* azurerm_lb_nat_rule.nlb_jumplb_nat: "location": [DEPRECATED] location is no longer used
  #location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id = "${azurerm_lb.nlb_jumplb.id}"
  name = "RDP"
  protocol = "Tcp"
  frontend_port = 50001
  backend_port = 3389
  frontend_ip_configuration_name = "${module.pubip.pubip_jumplb_name}"
}

output "nat_rule_ids" {
  value = ["${azurerm_lb_nat_rule.nlb_jumplb_nat.id}"]
}
