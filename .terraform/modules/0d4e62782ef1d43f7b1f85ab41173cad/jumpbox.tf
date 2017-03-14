variable "location"                                     { }
variable "resource_group_name"                          { }
variable "vm_jumpbox_name"                              { }
variable "vm_jumpbox_size"                              { }
variable "vm_jumpbox_user"                              { }
variable "vm_jumpbox_pwd"                               { }
variable "vm_jumpbox_nic_subnet"                        { }
variable "vm_jumpbox_ipconfig_lb_nat_rules"             { default = [] }
variable "vm_jumpbox_vhd_uri"                           { }

resource "azurerm_network_interface" "vm_jumpbox_nic" {
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  name = "${var.vm_jumpbox_name}-NIC"

    ip_configuration {
        name = "${var.vm_jumpbox_name}-ipconfig1"
        subnet_id = "${var.vm_jumpbox_nic_subnet}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.1.0.68"
        load_balancer_inbound_nat_rules_ids = []
    }
}

resource "azurerm_availability_set" "vm_jumpbox_as" {
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  name = "${var.vm_jumpbox_name}-AS"
}

resource "azurerm_virtual_machine" "vm_jumpbox" {
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    name = "${var.vm_jumpbox_name}"
    network_interface_ids = ["${azurerm_network_interface.vm_jumpbox_nic.id}"]
    vm_size = "${var.vm_jumpbox_size}"
    availability_set_id = "${azurerm_availability_set.vm_jumpbox_as.id}"

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name = "${var.vm_jumpbox_name}-OSDisk"
        vhd_uri = "${var.vm_jumpbox_vhd_uri}"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.vm_jumpbox_name}"
        admin_username = "${var.vm_jumpbox_user}"
        admin_password = "${var.vm_jumpbox_pwd}"
    }

    os_profile_windows_config {
        provision_vm_agent = "true"
        enable_automatic_upgrades = "true"
    }
}

resource "azurerm_virtual_machine_extension" "vmex_antimalware" {
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    name = "Antimalware"
    virtual_machine_name = "${azurerm_virtual_machine.vm_jumpbox.name}"
    publisher = "Microsoft.Azure.Security"
    type = "IaaSAntimalware"
    type_handler_version = "1.5"

    settings = <<SETTINGS
    {
      "AntimalwareEnabled": true,
          "Exclusions": {
              "Paths": "",
              "Extensions": "",
              "Processes": ""
          },
      "RealtimeProtectionEnabled": "true",
          "ScheduledScanSettings": {
              "isEnabled": "true",
              "scanType": "Quick",
              "day": "0",
              "time": "1080"
              }
    }
SETTINGS
}
