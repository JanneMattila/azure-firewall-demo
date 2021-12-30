param location string = resourceGroup().location

// Hub subnets are defined inside module
module hubVnet 'network/hub-virtual-network.bicep' = {
  name: 'hub-deployment'
  params: {
    name: 'vnet-hub'
    location: location
  }
}

module spoke001Vnet 'network/spoke-virtual-network.bicep' = {
  name: 'spoke001-deployment'
  params: {
    name: 'vnet-spoke001'
    location: location
    vnetAddressSpace: '10.1.0.0/22'
    subnetAddressSpace: '10.1.0.0/24' // Only 1 subnet in our spokes
  }
}
