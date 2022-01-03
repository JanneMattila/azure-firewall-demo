param parentName string

resource parentFirewall 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: parentName
}

resource spokesRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  name: 'Spoke-specific'
  parent: parentFirewall
  properties: {
    priority: 1000
    ruleCollections: [
      {
        name: 'Allow-Spoke001-To-Internet-Application-Rules'
        priority: 1000
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Spoke001 to bing.com'
            description: 'Allow spoke001 to connect to bing.com'
            sourceAddresses: [
              '10.1.0.0/22'
            ]
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            targetFqdns: [
              'bing.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Spoke001 to docs.microsoft.com'
            description: 'Allow spoke001 to connect to docs.microsoft.com'
            sourceAddresses: [
              '10.1.0.0/22'
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
      {
        name: 'Deny-Spoke002-To-Internet-Application-Rules'
        priority: 1011
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Deny'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Spoke002 to www.microsoft.com'
            description: 'Deny spoke003 to connect to www.microsoft.com'
            sourceAddresses: [
              '10.3.0.0/22'
            ]
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            targetFqdns: [
              'www.microsoft.com'
            ]
          }
        ]
      }
    ]
  }
}
