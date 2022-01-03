param parentName string

resource parentFirewall 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: parentName
}

resource commonRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-05-01' = {
  name: 'Common'
  parent: parentFirewall
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'Allow-Common-Network-Rules'
        priority: 101
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            // Justification:
            // https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/custom-routes-enable-kms-activation
            ruleType: 'NetworkRule'
            name: 'Azure-KMS-Service'
            description: 'Allow traffic from all address spaces to Azure platform KMS Service'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'kms.${environment().suffixes.storage}'
            ]
            destinationPorts: [
              '1688'
            ]
          }
        ]
      }
      {
        name: 'Allow-Common-Application-Rules'
        priority: 102
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Http'
            description: 'Allow traffic from all sources to Windows Update (http)'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            fqdnTags: [
              'WindowsUpdate'
            ]
            webCategories: []
            targetFqdns: []
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Https'
            description: 'Allow traffic from all sources to Windows Update (https)'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: [
              'WindowsUpdate'
            ]
            webCategories: []
            targetFqdns: []
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
      }
    ]
  }
}
