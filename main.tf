/*
Demo references

A Comprehensive Guide to Terraform
    https://blog.gruntwork.io/a-comprehensive-guide-to-terraform-b3d32832baca#.bj0gqve9j

Terraform Up and Running (Safari)
    https://www.safaribooksonline.com/library/view/terraform-up-and/9781491977071

Pete's Terraform Tips
    https://medium.com/@petey5000/petes-terraform-tips-694a3c4c5169#.dfdy6rlz1

Deploy a Best Practices Infrastructure in AWS (git)
      https://github.com/hashicorp/best-practices/tree/master/terraform/providers/aws

*/


#variables
variable "resource_group_name"                  { }
variable "location"                             { }

variable "virtual_network_name"                 { }
variable "vnet_address_space"                   { }

variable "subnet_app_name"                      { }
variable "subnet_app_prefix"                    { }
variable "subnet_dmz_name"                      { }
variable "subnet_dmz_prefix"                    { }
variable "subnet_db_name"                       { }
variable "subnet_db_prefix"                     { }
variable "subnet_maint_name"                    { }
variable "subnet_maint_prefix"                  { }
variable "subnet_gw_name"                       { }
variable "subnet_gw_prefix"                     { }

variable "pubip_jumplb_name"                    { }
variable "pubip_appgwlb_name"                   { }
variable "pubip_allocation"                     { }

variable "nlb_jumplb_name"                      { }

variable "storacct_disk_type"                   { }
variable "storacct_diag_type"                   { }

variable "vm_jumpbox_name"                      { }
variable "vm_jumpbox_size"                      { }
variable "vm_jumpbox_user"                      { }
variable "vm_jumpbox_pwd"                       { }

variable "vmss_iis_name"                        { }
variable "vmss_iis_size"                        { }
variable "vmss_iis_user"                        { }
variable "vmss_iis_pwd"                         { }
variable "vmss_php_name"                        { }
variable "vmss_php_size"                        { }
variable "vmss_php_user"                        { }
variable "vmss_php_pwd"                         { }

/*
provider config is set in session:
      export ARM_SUBSCRIPTION_ID=xxxx-xxxx-xxxx-xxxx-xxxx
      export ARM_CLIENT_ID=xxxx-xxxx-xxxx-xxxx-xxxx
      export ARM_CLIENT_SECRET=******************************
      export ARM_TENANT_ID=xxxx-xxxx-xxxx-xxxx-xxxx
*/
provider "azurerm" {
}

module "resource" {
  source = "./resource"

  resource_group_name = "${var.resource_group_name}"
  location = "${var.location}"
}

module "vnet" {
  source = "./network/vnet"

  location = "${var.location}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name = "${var.resource_group_name}"
  vnet_address_space = "${var.vnet_address_space}"
}

module "nsg" {
  source = "./network/nsg"

  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

module "subnet" {
  source = "./network/subnet"

  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${module.vnet.name}"
  subnet_app_name = "${var.subnet_app_name}"
  subnet_app_prefix = "${var.subnet_app_prefix}"
  subnet_app_nsg = "${module.nsg.default_id}"
  subnet_dmz_name = "${var.subnet_dmz_name}"
  subnet_dmz_prefix = "${var.subnet_dmz_prefix}"
  subnet_dmz_nsg = "${module.nsg.web_id}"
  subnet_db_name = "${var.subnet_db_name}"
  subnet_db_prefix = "${var.subnet_db_prefix}"
  subnet_db_nsg = "${module.nsg.default_id}"
  subnet_maint_name = "${var.subnet_maint_name}"
  subnet_maint_prefix = "${var.subnet_maint_prefix}"
  subnet_maint_nsg = "${module.nsg.maint_id}"
  subnet_gw_name = "${var.subnet_gw_name}"
  subnet_gw_prefix = "${var.subnet_gw_prefix}"
  subnet_gw_nsg = "${module.nsg.vpngw_id}"
}

module "pubip" {
  source = "./network/pubip"

  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  pubip_jumplb_name = "${var.pubip_jumplb_name}"
  pubip_appgwlb_name = "${var.pubip_appgwlb_name}"
  pubip_allocation = "${var.pubip_allocation}"
}

module "nlb" {
  source = "./network/nlb"

  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  nlb_jumplb_name = "${var.nlb_jumplb_name}"
  pubip_jumplb_name = "${var.pubip_jumplb_name}"
  pubip_appgwlb_name = "${var.pubip_appgwlb_name}"
  pubip_allocation = "${var.pubip_allocation}"
}

module "storage" {
    source = "./data/storage"

    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    storacct_disk_type = "${var.storacct_disk_type}"
    storacct_diag_type = "${var.storacct_diag_type}"
  }

module "jumpbox" {
    source = "./compute/jumpbox"

    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    vm_jumpbox_name = "${var.vm_jumpbox_name}"
    vm_jumpbox_size = "${var.vm_jumpbox_size}"
    vm_jumpbox_user = "${var.vm_jumpbox_user}"
    vm_jumpbox_pwd = "${var.vm_jumpbox_pwd}"
    vm_jumpbox_nic_subnet = "${module.subnet.subnet_maint_id}"
    vm_jumpbox_ipconfig_lb_nat_rules = ["${module.nlb.nat_rule_ids}"]
    vm_jumpbox_vhd_uri = "${module.storage.storacct_disk_primary_blob_endpoint}${module.storage.storacct_disk_vhd_container_name}/${var.vm_jumpbox_name}-OSDisk.vhd"
}

module "web-iis" {
    source = "./compute/web-iis"

    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    vmss_iis_name = "${var.vmss_iis_name}"
    vmss_iis_size = "${var.vmss_iis_size}"
    vmss_iis_user = "${var.vmss_iis_user}"
    vmss_iis_pwd = "${var.vmss_iis_pwd}"
    vmss_iis_nic_subnet = "${module.subnet.subnet_app_id}"
    vmss_iis_vhd_containers = ["${module.storage.storacct_disk_primary_blob_endpoint}${module.storage.storacct_disk_vhd_container_name}"]
}

module "web-php" {
    source = "./compute/web-php"

    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    vmss_php_name = "${var.vmss_php_name}"
    vmss_php_size = "${var.vmss_php_size}"
    vmss_php_user = "${var.vmss_iis_user}"
    vmss_php_pwd = "${var.vmss_iis_pwd}"
    vmss_php_nic_subnet = "${module.subnet.subnet_app_id}"
    vmss_php_vhd_containers = ["${module.storage.storacct_disk_primary_blob_endpoint}${module.storage.storacct_disk_vhd_container_name}"]
}

module "appgw" {
  source = "./network/appgw"

  resource_group_name = "${var.resource_group_name}"
}
