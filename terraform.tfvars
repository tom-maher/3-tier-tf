#--------------------------------------------------------------
# General
#--------------------------------------------------------------

resource_group_name       = "3-tier-tf-rg"
location                  = "UK West"

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

virtual_network_name      = "3-tier-vnet"
vnet_address_space        = "10.1.0.0/24"
subnet_app_name           = "Applications"
subnet_app_prefix         = "10.1.0.0/27"
subnet_dmz_name           = "DMZ"
subnet_dmz_prefix         = "10.1.0.32/28"
subnet_db_name            = "Databases"
subnet_db_prefix          = "10.1.0.48/28"
subnet_maint_name         = "Maintanence"
subnet_maint_prefix       = "10.1.0.64/29"
subnet_gw_name            = "GatewaySubnet"
subnet_gw_prefix          = "10.1.0.248/29"

pubip_jumplb_name         = "3TierLB-IP"
pubip_appgwlb_name        = "3TierAPPGW-IP"
pubip_allocation          = "Static"

nlb_jumplb_name           = "3TierJumpBox-LB"

#--------------------------------------------------------------
# Storage
#--------------------------------------------------------------

storacct_disk_type        = "Standard_LRS"
storacct_diag_type        = "Standard_LRS"

#--------------------------------------------------------------
# Compute
#--------------------------------------------------------------

vm_jumpbox_name           = "JumpBox"
vm_jumpbox_size           = "Standard_F1"
vm_jumpbox_user           = "azadmin"
vm_jumpbox_pwd            = "~@!P@ssw0rd~@!"

vmss_iis_name             = "IIS"
vmss_iis_size             = "Standard_F1"
vmss_iis_user               = "azadmin"
vmss_iis_pwd                = "~@!P@ssw0rd~@!"

vmss_php_name             = "PHPWeb"
vmss_php_size             = "Standard_F1"
vmss_php_user               = "azadmin"
vmss_php_pwd                = "~@!P@ssw0rd~@!"
