param name string
param tag string
param hubName string
param hubId string
param vnetAddressSpace string
param subnetAddressSpace string
param location string = resourceGroup().location

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  tags: {
    'azfw-mapping': tag
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'snet-front'
        properties: {
          addressPrefix: subnetAddressSpace
        }
      }
    ]
  }
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${virtualNetwork.name}/spoke-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: hubId
    }
  }
}

resource HubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${hubName}/hub-to-${name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

output id string = virtualNetwork.id
output subnetId string = virtualNetwork.properties.subnets[0].id
