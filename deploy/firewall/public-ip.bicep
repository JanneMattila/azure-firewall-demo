param name string
param location string = resourceGroup().location

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

output id string = publicIPAddress.id
