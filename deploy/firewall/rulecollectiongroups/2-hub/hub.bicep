param parentName string

resource parentFirewall 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: parentName
}

resource hubRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  name: 'Hub-specific'
  parent: parentFirewall
  properties: {
    priority: 200
    ruleCollections: [
      {
        name: 'Allow-Hub-Network-Rules'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        priority: 201
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Hub to spokes'
            description: 'Allow hub to spokes traffic'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '10.0.3.0/24' // snet-management subnet
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.1.0.0/22' // spoke001
              '10.2.0.0/22' // spoke002
              '10.3.0.0/22' // spoke003
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
