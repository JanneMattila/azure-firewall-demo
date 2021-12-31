param name string
param parentName string
param location string

resource parentFirewall 'Microsoft.Network/azureFirewalls@2020-11-01' existing = {
  name: parentName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: location
}

resource diagnosticSettings 'microsoft.insights/diagnosticSettings@2016-09-01' = {
  name: name
  scope: parentFirewall
  location: location
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
      }
      {
        category: 'AzureFirewallDnsProxy'
        enabled: true
      }
    ]
  }
}

output workspaceId string = logAnalyticsWorkspace.properties.customerId
