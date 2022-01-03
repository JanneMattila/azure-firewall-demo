param parentName string

resource parentFirewall 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: parentName
}

resource vnetRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  name: 'VNET'
  parent: parentFirewall
  properties: {
    priority: 200
    ruleCollections: [
      {
        name: 'vnet-to-internet'
        priority: 202
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Spoke001 to internet'
            description: 'Allow spoke001 to connect to internet'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '10.1.0.0/22'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '80'
              '443'
            ]
          }
        ]
      }
      {
        name: 'vnet-to-vnet'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        priority: 203
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Spoke002 to spoke001'
            description: 'Allow spoke002 to spoke001 traffic'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '10.2.0.0/22'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.1.0.0/22'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
        ]
      }
    ]
  }
}
