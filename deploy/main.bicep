param location string = resourceGroup().location

module virtualNetworks 'network/virtual-networks.bicep' = {
  name: 'virtual-networks-deployment'
  params: {
    location: location
  }
}

output virtualNetworks object = virtualNetworks
