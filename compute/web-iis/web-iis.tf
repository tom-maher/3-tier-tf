variable "location"                           { }
variable "resource_group_name"                { }
variable "vmss_iis_name"                      { }
variable "vmss_iis_size"                      { }
variable "vmss_iis_user"                      { }
variable "vmss_iis_pwd"                       { }
variable "vmss_iis_nic_subnet"                { }
variable "vmss_iis_vhd_containers"            { default = [] }

resource "azurerm_virtual_machine_scale_set" "vmss_iis" {
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  name = "${var.vmss_iis_name}"
  upgrade_policy_mode = "Manual"

  sku {
    name = "${var.vmss_iis_size}"
    tier = "Standard"
    capacity = 2
  }

  os_profile {
    computer_name_prefix = "${var.vmss_iis_name}"
    admin_username = "${var.vmss_iis_user}"
    admin_password = "${var.vmss_iis_pwd}"
  }

  os_profile_windows_config {
      provision_vm_agent = "true"
      enable_automatic_upgrades = "true"
  }

  network_profile {
      name = "${var.vmss_iis_name}-NetProfile"
      primary = true
      ip_configuration {
        name = "${var.vmss_iis_name}-ipconfig1"
        subnet_id = "${var.vmss_iis_nic_subnet}"
      }
  }

  storage_profile_os_disk {
    name = "${var.vmss_iis_name}-OSDisk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    vhd_containers = ["${var.vmss_iis_vhd_containers}"]
}

  storage_profile_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2016-Datacenter"
    version = "latest"
  }
}

/*
VMExtensions for VMSS not currently supported (01/03)
https://github.com/hashicorp/terraform/pull/12124

resource "azurerm_virtual_machine_extension" "vmex_antimalware" {
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    name = "Antimalware"
    virtual_machine_name = "${azurerm_virtual_machine_scale_set.vmss_iis.name}"
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

resource "azurerm_virtual_machine_extension" "vmex_dsc" {
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    name = "DSC"
    virtual_machine_name = "${azurerm_virtual_machine_scale_set.vmss_iis.name}"
    publisher = "Microsoft.Powershell"
    type = "DSC"
    type_handler_version = "2.22"

    settings = <<SETTINGS
    {
        "configuration": {
          "url": "https://github.com/tom-maher/staging/blob/master/WebServer.ps1.zip",
          "script": "WebServer.ps1",
          "function": "WebServer"
        },
          "privacy": {
              "dataCollection": "enable"
          }
    }
SETTINGS
}*/
