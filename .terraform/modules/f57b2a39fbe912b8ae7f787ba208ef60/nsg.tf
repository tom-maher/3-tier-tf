variable "location"                         { }
variable "resource_group_name"              { }

#Default NSG
resource "azurerm_network_security_group" "default" {
    name = "Default"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    #Allow 443 inbound from internet
    security_rule {
        name = "RDPfromJumpBox"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = "3389"
        source_address_prefix = "10.1.0.64/29"
        destination_address_prefix = "10.1.0.0/27"
    }
    #Deny RDP from anywhere
    security_rule {
        name = "BlockRDP"
        priority = 200
        direction = "Inbound"
        access = "Deny"
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = "3389"
        source_address_prefix = "*"
        destination_address_prefix = "10.1.0.0/27"
    }
}

#maintenance NSG
resource "azurerm_network_security_group" "maintenance" {
    name = "Maintenance"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    #Allow 3389 inbound from internet
    security_rule {
        name = "RDPtoJumpbox"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = "3389"
        source_address_prefix = "*"
        destination_address_prefix = "10.1.0.64/29"
    }
}

#VPNGateway
resource "azurerm_network_security_group" "vpngw" {
    name = "VPNGateway"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    #Allow 443 inbound from internet
    security_rule {
        name = "AllowHttps"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = "443"
        source_address_prefix = "*"
        destination_address_prefix = "VirtualNetwork"
    }
}

#Web
resource "azurerm_network_security_group" "web" {
    name = "Web"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    #Allow 80 inbound from internet
    security_rule {
        name = "AllowHttp"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = "80"
        source_address_prefix = "*"
        destination_address_prefix = "VirtualNetwork"
    }
    #Allow 443 inbound from internet
    security_rule {
        name = "AllowHttps"
        priority = 110
        direction = "Inbound"
        access = "Allow"
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = "443"
        source_address_prefix = "*"
        destination_address_prefix = "VirtualNetwork"
    }
}


output "default_id" {
  value = "${azurerm_network_security_group.default.id}"
}

output "maint_id" {
  value = "${azurerm_network_security_group.maintenance.id}"
}

output "vpngw_id" {
  value = "${azurerm_network_security_group.vpngw.id}"
}

output "web_id" {
  value = "${azurerm_network_security_group.web.id}"
}


###
### do not reference beneath these lines
###
#Application servers NSG
/*resource "azurerm_network_security_group" "dlmc-appsvr-nsg" {
    name = "dlmc-appsvr-nsg"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    #Allow 3389 inbound from management subnet
    security_rule {
        name = "iba-vnet-3389-1000"
        priority = 1000
        direction = "Inbound"
        access = "Allow"
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = "3389"
        source_address_prefix = "10.1.0.64/29"
        destination_address_prefix = "*"
    }
    #Allow 22 inbound from management subnet
    security_rule {
        name = "iba-vnet-22-1010"
        priority = 1010
        direction = "Inbound"
        access = "Allow"
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "10.1.0.64/29"
        destination_address_prefix = "*"
    }
}

# Data tier NSG
resource "azurerm_network_security_group" "dlmc-data-nsg" {
    name = "dlmc-data-nsg"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    #Allow 1433 inbound from management subnet
    security_rule {
        name = "iba-vnet-1433-1000"
        priority = 1000
        direction = "Inbound"
        access = "Allow"
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = "1433"
        source_address_prefix = "10.1.0.0/27"
        destination_address_prefix = "*"
    }
}*/
