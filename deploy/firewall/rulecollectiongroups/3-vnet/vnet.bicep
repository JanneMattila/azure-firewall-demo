param parentName string

resource parentFirewall 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: parentName
}

resource vnetRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  name: 'VNET'
  parent: parentFirewall
  properties: {
    priority: 300
    ruleCollections: [
      {
        name: 'Allow-VNET-To-VNET-Network-Rules'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        priority: 301
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Spoke001 to spoke002'
            description: 'Allow spoke001 to spoke002 traffic'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '10.1.0.0/22' // spoke001
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.2.0.0/22' // spoke002
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Spoke002 to spoke001'
            description: 'Allow spoke002 to spoke001 traffic'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '10.2.0.0/22' // spoke002
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.1.0.0/22' // spoke001
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
        ]
      }
      {
        name: 'Allow-VNET-To-Internet-Application-Rules'
        priority: 302
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Spoke001 to github.com'
            description: 'Allow spoke001 to connect to github.com'
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
              'github.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'All vnets to www.microsoft.com'
            description: 'Allow vnets to connect to www.microsoft.com'
            sourceAddresses: [
              '*'
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
      {
        name: 'Allow-VNET-To-VNET-Application-Rules'
        priority: 303
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Spoke001 to spoke003 ACI using http'
            description: 'Allow spoke001 to connect to Azure Container Instance deployed to spoke003 using http on port 80'
            sourceAddresses: [
              '10.1.0.0/22' // spoke001
            ]
            protocols: [
              {
                port: 80
                protocolType: 'Http'
              }
            ]
            targetFqdns: [
              '10.3.0.4' // spoke003 - Azure Container Instance
            ]
          }
        ]
      }
    ]
  }
}
