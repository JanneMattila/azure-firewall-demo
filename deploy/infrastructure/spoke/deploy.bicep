param spokeName string
param vnetAddressSpace string
param subnetAddressSpace string
param hubName string
param hubId string
param routeTableId string
param location string = resourceGroup().location

var vnetName = 'vnet-${spokeName}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  tags: {
    'azfw-mapping': spokeName
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
          routeTable: {
            id: routeTableId
          }
          delegations: [
            {
              name: 'ACIDelegation'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
    ]
  }
}

module aci 'container-instances.bicep' = {
  name: '${spokeName}-aci-deployment'
  params: {
    name: 'ci-${spokeName}'
    location: location
    subnetId: virtualNetwork.properties.subnets[0].id
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
  name: '${hubName}/hub-to-${vnetName}'
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
