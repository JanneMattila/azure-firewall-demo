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

module ruleCollectionGroups 'rulecollectiongroups/deploy.bicep' = {
  name: 'ruleCollectionGroups-deployment'
  params: {
    parentName: firewallPolicy.name
  }
}

output id string = firewallPolicy.id
