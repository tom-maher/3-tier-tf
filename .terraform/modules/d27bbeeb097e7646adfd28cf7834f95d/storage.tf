variable "location"                                 { }
variable "resource_group_name"                      { }
variable "storacct_disk_type"                       { }
variable "storacct_diag_type"                       { }

resource "azurerm_storage_account" "storacct_disk" {
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  name = "sadisk${format("%.8s", lower(sha1("${var.resource_group_name}")))}"
  account_type = "${var.storacct_disk_type}"
}

resource "azurerm_storage_container" "vhds" {
  name = "vhds"
  resource_group_name = "${var.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.storacct_disk.name}"
  container_access_type = "private"
}

resource "azurerm_storage_account" "storacct_state" {
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  name = "sadisk${format("%.8s", lower(sha1("${var.resource_group_name}")))}"
  account_type = "${var.storacct_disk_type}"
}

resource "azurerm_storage_container" "state" {
  name = "state"
  resource_group_name = "${var.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.storacct_state.name}"
  container_access_type = "private"
}

resource "azurerm_storage_account" "storacct_diag" {
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  name = "sadiag${format("%.8s", lower(sha1("${var.resource_group_name}")))}"
  account_type = "${var.storacct_diag_type}"
}

output "storacct_disk_id" {
  value = "azurerm_storage_account.storacct_disk.id"
}

output "storacct_disk_primary_blob_endpoint" {
  value = "${azurerm_storage_account.storacct_disk.primary_blob_endpoint}"
}

output "storacct_disk_vhd_container_name" {
  value = "${azurerm_storage_container.vhds.name}"
}
