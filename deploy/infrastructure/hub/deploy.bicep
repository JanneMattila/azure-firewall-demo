param name string
param username string
@secure()
param password string
param gatewaySubnetRouteTableId string
param location string

var bastionName = 'bas-management'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/21'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          routeTable: {
            id: gatewaySubnetRouteTableId
          }
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        // For intrastructure resources e.g., DCs
        name: 'snet-infra'
        properties: {
          addressPrefix: '10.0.2.0/24'
          // If you further expand this demo, then most likely
          // you need to implement route table for this specific
          // subnet as well.
        }
      }
      {
        // For our demo management subnet to host our VMs
        name: 'snet-management'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.4.0/24'
        }
      }
    ]
  }
}

var gatewaySubnetId = virtualNetwork.properties.subnets[0].id
var firewallSubnetId = virtualNetwork.properties.subnets[1].id
var managementSubnetId = virtualNetwork.properties.subnets[3].id
var bastionSubnetId = virtualNetwork.properties.subnets[4].id

module vpn 'vpn.bicep' = {
  name: 'vpn-deployment'
  params: {
    name: 'vgw-vpn'
    location: location
    subnetId: gatewaySubnetId
  }
}

module bastion 'bastion.bicep' = {
  name: 'bastion-deployment'
  params: {
    name: bastionName
    location: location
    subnetId: bastionSubnetId
  }
}

module jumpbox 'jumpbox.bicep' = {
  name: 'jumpbox-deployment'
  params: {
    name: 'jumpbox'
    username: username
    password: password
    location: location
    subnetId: managementSubnetId
  }
}

output id string = virtualNetwork.id
output name string = virtualNetwork.name
output bastionName string = bastionName
output gatewaySubnetId string = gatewaySubnetId
output firewallSubnetId string = firewallSubnetId
output managementSubnetId string = managementSubnetId
output bastionSubnetId string = bastionSubnetId
output virtualMachineResourceId string = jumpbox.outputs.virtualMachineResourceId
