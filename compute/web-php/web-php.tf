variable "location"                               { }
variable "resource_group_name"                    { }
variable "vmss_php_name"                          { }
variable "vmss_php_size"                          { }
variable "vmss_php_user"                          { }
variable "vmss_php_pwd"                           { }
variable "vmss_php_nic_subnet"                    { }
variable "vmss_php_vhd_containers"                { default = []}

resource "azurerm_virtual_machine_scale_set" "vmss_php" {
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  name = "${var.vmss_php_name}"
  upgrade_policy_mode = "Manual"

  sku {
    name = "${var.vmss_php_size}"
    tier = "Standard"
    capacity = 2
  }

  os_profile {
    computer_name_prefix = "${var.vmss_php_name}"
    admin_username = "${var.vmss_php_user}"
    admin_password = "${var.vmss_php_pwd}"
    custom_data = "${base64encode("#!/bin/bash")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/azadmin/.ssh/authorized_keys"
      key_data = "ssh-rsa ********************************************* alice"
    }
  }

  network_profile {
      name = "${var.vmss_php_name}-NetProfile"
      primary = true
      ip_configuration {
        name = "${var.vmss_php_name}-ipconfig1"
        subnet_id = "${var.vmss_php_nic_subnet}"
      }
  }

  storage_profile_os_disk {
    name = "${var.vmss_php_name}-OSDisk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    vhd_containers = ["${var.vmss_php_vhd_containers}"]
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
