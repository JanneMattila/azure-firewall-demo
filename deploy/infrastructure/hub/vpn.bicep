param name string
param location string
param subnetId string

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'pip-vpn'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'vpn-pip1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    activeActive: false
    enableBgp: true
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation1'

    // Other properties to evaluate:
    // bgpSettings: {
    //   asn: asn
    // }
  }
}

output vpnResourceId string = virtualNetworkGateway.id
