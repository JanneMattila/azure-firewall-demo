param parentName string

resource parentFirewall 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: parentName
}

resource vnetRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  name: 'On-premises'
  parent: parentFirewall
  properties: {
    priority: 300
    ruleCollections: [
      {
        name: 'on-premises-to-vnet'
        priority: 301
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
      }
      {
        name: 'vnet-to-on-premises'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        priority: 302
        action: {
          type: 'Allow'
        }
        rules: []
      }
    ]
  }
}
