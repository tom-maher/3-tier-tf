variable "resource_group_name"                 { }

resource "azurerm_template_deployment" "appgw" {
  resource_group_name = "${var.resource_group_name}"
  name = "appgw-deploy-01"
  deployment_mode = "Incremental"
  parameters {
    vNetResourceGroup = "${var.resource_group_name}"
    vNetName = "3-tier-vnet"
    subnetName = "DMZ"
    applicationGatewayName = "3TierAPPGW"
  }
  template_body = <<DEPLOY
  {
      "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
      "contentVersion": "0.1.0.0",
      "parameters": {
          "vNetResourceGroup": {
              "type": "string",
              "metadata": {
                  "description": "The resource group the vNet is deployed to."
              }
          },
          "vNetName": {
              "type": "string",
              "metadata": {
                  "description": "The name of the vNet."
              }
          },
          "subnetName": {
              "type": "string",
              "metadata": {
                  "description": "The name of the sub-net that the Application Gateway will be deployed to."
              }
          },
          "applicationGatewayName": {
              "type": "string",
              "defaultValue": "applicationGateway1",
              "metadata": {
                  "description": "application gateway name"
              }
          },
          "applicationGatewaySize": {
              "type": "string",
              "allowedValues": [
                  "Standard_Small",
                  "Standard_Medium",
                  "Standard_Large"
              ],
              "defaultValue": "Standard_Small",
              "metadata": {
                  "description": "application gateway size"
              }
          },
          "applicationGatewayInstanceCount": {
              "type": "int",
              "allowedValues": [
                  1,
                  2,
                  3,
                  4,
                  5,
                  6,
                  7,
                  8,
                  9,
                  10
              ],
              "defaultValue": 2,
              "metadata": {
                  "description": "application gateway instance count"
              }
          },
          "cookieBasedAffinity": {
              "type": "string",
              "allowedValues": [
                  "Enabled",
                  "Disabled"
              ],
              "defaultValue": "Disabled",
              "metadata": {
                  "description": "cookie based affinity"
              }
          }
      },
      "variables": {
          "location": "[resourceGroup().location]",
          "vnetId": "[resourceId(parameters('vNetResourceGroup'),'Microsoft.Network/virtualNetworks', parameters('vNetName'))]",
          "subnetRef": "[concat(variables('vnetId'), '/subnets/', parameters('subnetName'))]",
          "appGatewayIP": "[concat(parameters('applicationGatewayName'), '-ip')]"
      },
      "resources": [
          {
              "name": "[variables('appGatewayIP')]",
              "type": "Microsoft.Network/publicIPAddresses",
              "comments": "The public IP address of the application gateway.",
              "apiVersion": "2016-03-30",
              "location": "[variables('location')]",
              "properties": {
                  "publicIPAllocationMethod": "Dynamic"
              }
          },
          {
              "name": "[parameters('applicationGatewayName')]",
              "type": "Microsoft.Network/applicationGateways",
              "apiVersion": "2016-12-01",
              "location": "[variables('location')]",
              "dependsOn": [
                  "[concat('Microsoft.Network/publicIPAddresses/', variables('appGatewayIP'))]"
              ],
              "properties": {
                  "sku": {
                      "name": "[parameters('applicationGatewaySize')]",
                      "tier": "Standard",
                      "capacity": "[parameters('applicationGatewayInstanceCount')]"
                  },
                  "gatewayIPConfigurations": [
                      {
                          "name": "appGatewayIpConfig",
                          "properties": {
                              "subnet": {
                                  "id": "[variables('subnetRef')]"
                              }
                          }
                      }
                  ],
                  "sslCertificates": null,
                  "authenticationCertificates": [],
                  "frontendIPConfigurations": [
                      {
                          "name": "appGatewayPublicIP",
                          "properties": {
                              "publicIPAddress": {
                                  "id": "[resourceId('Microsoft.Network/publicIPAddresses', variables('appGatewayIP'))]"
                              }
                          }
                      }
                  ],
                  "frontendPorts": [
                      {
                          "name": "appGatewayFrontendPort",
                          "properties": {
                              "Port": 80
                          }
                      }
                  ],
                  "backendAddressPools": [
                      {
                          "name": "defaultBackendPool"
                      },
                      {
                          "name": "apache"
                      }
                  ],
                  "backendHttpSettingsCollection": [
                      {
                          "name": "appGatewayBackendHttpSettings",
                          "properties": {
                              "Port": 80,
                              "Protocol": "Http",
                              "CookieBasedAffinity": "[parameters('cookieBasedAffinity')]"
                          }
                      }
                  ],
                  "httpListeners": [
                      {
                          "name": "appGatewayHttpListener",
                          "properties": {
                              "FrontendIpConfiguration": {
                                  "Id": "[resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', parameters('applicationGatewayName'), 'appGatewayPublicIP')]"
                              },
                              "FrontendPort": {
                                  "Id": "[resourceId('Microsoft.Network/applicationGateways/frontendPorts', parameters('applicationGatewayName'), 'appGatewayFrontendPort')]"
                              },
                              "Protocol": "Http",
                              "SslCertificate": null,
                              "requireServerNameIndication": false
                          }
                      }
                  ],
                  "urlPathMaps": [
                      {
                          "name": "appGatewayPathMap",
                          "properties": {
                              "defaultBackendAddressPool": {
                                  "id": "[resourceId('Microsoft.Network/applicationGateways/backendAddressPools', parameters('applicationGatewayName'), 'defaultBackendPool')]"
                              },
                              "defaultBackendHttpSettings": {
                                  "id": "[resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', parameters('applicationGatewayName'), 'appGatewayBackendHttpSettings')]"
                              },
                              "pathRules": [
                                  {
                                      "name": "Apache",
                                      "properties": {
                                          "provisioningState": "Succeeded",
                                          "paths": [
                                              "/apache/*"
                                          ],
                                          "backendAddressPool": {
                                              "id": "[resourceId('Microsoft.Network/applicationGateways/backendAddressPools', parameters('applicationGatewayName'), 'apache')]"
                                          },
                                          "backendHttpSettings": {
                                              "id": "[resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', parameters('applicationGatewayName'), 'appGatewayBackendHttpSettings')]"
                                          }
                                      }
                                  }
                              ]
                          }
                      }
                  ],
                  "requestRoutingRules": [
                      {
                          "Name": "DefaultWebServer",
                          "properties": {
                              "RuleType": "PathBasedRouting",
                              "httpListener": {
                                  "id": "[resourceId('Microsoft.Network/applicationGateways/httpListeners', parameters('applicationGatewayName'), 'appGatewayHttpListener')]"
                              },
                              "urlPathMap": {
                                  "id": "[resourceId('Microsoft.Network/applicationGateways/urlPathMaps', parameters('applicationGatewayName'), 'appGatewayPathMap')]"
                              }
                          }
                      }
                  ]
              }
          }
      ],
      "outputs": {}
  }
DEPLOY
}
