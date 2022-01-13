param name string
param location string

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

output id string = publicIPAddress.id
