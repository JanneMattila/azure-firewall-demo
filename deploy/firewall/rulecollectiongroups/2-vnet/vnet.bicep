param name string
param parentName string

resource parentFirewall 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: parentName
}

module vnet_to_vnet 'vnet_to_vnet.bicep' = {
  name: 'vnet_to_vnet-deployment'
}

// module vnet_to_internet 'vnet_to_internet.bicep' = {
//   name: 'vnet_to_internet-deployment'
//   params: {
//     name: 'vnet_to_internet'
//     parentName: parentFirewall.name
//   }
// }

resource vnetRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  name: name
  parent: parentFirewall
  properties: {
    priority: 200
    ruleCollections: [
      vnet_to_vnet.outputs.vnet_to_internet
      // vnet_to_internet.outputs.
    ]
  }
}
