param name string
param parentName string

resource parentFirewall 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: parentName
}

resource spokesRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  name: name
  parent: parentFirewall
  properties: {
    priority: 1000
    ruleCollections: [
      {
        name: 'spokes001'
        priority: 1000
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
      }
      {
        name: 'spokes002'
        priority: 1000
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
      }
    ]
  }
}
