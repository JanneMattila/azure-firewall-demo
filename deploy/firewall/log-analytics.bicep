param name string
param parentName string
param location string

resource parentFirewall 'Microsoft.Network/azureFirewalls@2020-11-01' existing = {
  name: parentName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'log-firewall'
  location: location
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: name
  scope: parentFirewall
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
