param parentName string

resource parentFirewall 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: parentName
}

resource spokesRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  name: 'Spoke-specific'
  parent: parentFirewall
  properties: {
    priority: 500
    ruleCollections: [
      {
        name: 'Allow-Spoke001-To-Internet-Application-Rules'
        priority: 501
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Spoke001 to www.bing.com'
            description: 'Allow spoke001 to connect to www.bing.com'
            sourceAddresses: [
              '10.1.0.0/22' // spoke001
            ]
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            targetFqdns: [
              'www.bing.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Spoke001 to docs.microsoft.com'
            description: 'Allow spoke001 to connect to docs.microsoft.com'
            sourceAddresses: [
              '10.1.0.0/22' // spoke001
            ]
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            targetFqdns: [
              'docs.microsoft.com'
            ]
          }
        ]
      }
    ]
  }
}
