param name string
param vnetAddressSpace string
param subnetAddressSpace string
param location string = resourceGroup().location

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'snet-front'
        properties: {
          addressPrefix: subnetAddressSpace
        }
      }
    ]
  }
}

output virtualNetwork object = virtualNetwork
