param firewallPolicyId string
param ip object
param name string
@allowed([
  'AZFW_Hub'
  'AZFW_VNet'
])
param skuName string = 'AZFW_VNet'
@allowed([
  'Premium'
  'Standard'
])
param skuTier string = 'Standard'
param location string = resourceGroup().location

resource firewall 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: name
  location: location
  properties: {
    threatIntelMode: 'Alert'
    sku: {
      name: skuName
      tier: skuTier
    }
    firewallPolicy: {
      id: firewallPolicyId
    }
    applicationRuleCollections: []
    natRuleCollections: []
    networkRuleCollections: []
    ipConfigurations: [
      {
        name: 'fw-pip1'
        properties: {
          subnet: {
            id: ip.subnet
          }
          publicIPAddress: {
            id: ip.publicIp
          }
        }
      }
    ]
  }
}

output privateIPAddress string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
