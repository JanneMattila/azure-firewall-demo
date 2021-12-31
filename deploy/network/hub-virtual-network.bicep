param name string
param location string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/22'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
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

output id string = virtualNetwork.id
output name string = virtualNetwork.name
output gatewaySubnetId string = virtualNetwork.properties.subnets[0].id
output firewallSubnetId string = virtualNetwork.properties.subnets[1].id
output bastionSubnetId string = virtualNetwork.properties.subnets[4].id
