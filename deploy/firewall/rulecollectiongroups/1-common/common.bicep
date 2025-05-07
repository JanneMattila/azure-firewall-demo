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
            // https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/custom-routes-enable-kms-activation
            ruleType: 'NetworkRule'
            name: 'Azure KMS Service'
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
              'azkms.${environment().suffixes.storage}'
              'kms.${environment().suffixes.storage}'
            ]
            destinationPorts: [
              '1688'
            ]
          }
          {
            // Justification:
            // https://learn.microsoft.com/en-us/azure/security/fundamentals/azure-ca-details?tabs=root-and-subordinate-cas-list#certificate-downloads-and-revocation-lists
            ruleType: 'NetworkRule'
            name: 'Certificate CRL'
            description: 'Allow certificate downloads and revocation lists'
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
              'oneocsp.microsoft.com'
              'www.microsoft.com'
            ]
            destinationPorts: [
              '80'
            ]
          }
          {
            // Justification:
            // https://learn.microsoft.com/en-us/troubleshoot/windows-client/networking/internet-explorer-edge-open-connect-corporate-public-network
            ruleType: 'NetworkRule'
            name: 'Windows Internet connectivity test'
            description: 'Allow Windows to check that the computer is connected to the Internet'
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
              'www.msftconnecttest.com'
            ]
            destinationPorts: [
              '443'
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
            name: 'Windows Update'
            description: 'Allow traffic from all sources to Windows Update'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
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
          {
            ruleType: 'ApplicationRule'
            name: 'Ubuntu Updates'
            description: 'Allow traffic from all sources to Ubuntu Updates'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              'security.ubuntu.com'
              'archive.ubuntu.com'
              'azure.archive.ubuntu.com'
            ]
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
            name: 'Installations'
            description: 'Allow traffic from all sources for fetching installation files'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              // Installation scripts from GitHub
              'raw.githubusercontent.com'
              'objects.githubusercontent.com'
              'github.com'

              // .NET related installation files
              'builds.dotnet.microsoft.com'
            ]
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
