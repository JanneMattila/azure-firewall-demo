param name string
@allowed([
  'Premium'
  'Standard'
])
param tier string = 'Standard'
param location string = resourceGroup().location

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: name
  location: location
  properties: {
    sku: {
      tier: tier
    }
    threatIntelMode: 'Deny'
    dnsSettings: {
      servers: []
      enableProxy: true
    }
  }
}

output id string = firewallPolicy.id
