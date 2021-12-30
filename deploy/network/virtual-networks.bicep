param location string

var hubName = 'vnet-hub'
var spoke001Name = 'vnet-spoke001'
var spoke002Name = 'vnet-spoke002'
var spoke003Name = 'vnet-spoke003'

// Hub subnets are defined inside module
module hubVirtualNetwork 'hub-virtual-network.bicep' = {
  name: 'hub-deployment'
  params: {
    name: hubName
    location: location
  }
}

module spoke001VirtualNetwork 'spoke-virtual-network.bicep' = {
  name: '${spoke001Name}-deployment'
  params: {
    name: spoke001Name
    hubName: hubName
    hubId: hubVirtualNetwork.outputs.id
    location: location
    vnetAddressSpace: '10.1.0.0/22'
    subnetAddressSpace: '10.1.0.0/24' // Only 1 subnet in our spokes
  }
}

module spoke002VirtualNetwork 'spoke-virtual-network.bicep' = {
  name: '${spoke002Name}-deployment'
  params: {
    name: spoke002Name
    hubName: hubName
    hubId: hubVirtualNetwork.outputs.id
    location: location
    vnetAddressSpace: '10.2.0.0/22'
    subnetAddressSpace: '10.2.0.0/24' // Only 1 subnet in our spokes
  }
}

module spoke003VirtualNetwork 'spoke-virtual-network.bicep' = {
  name: '${spoke003Name}-deployment'
  params: {
    name: spoke003Name
    hubName: hubName
    hubId: hubVirtualNetwork.outputs.id
    location: location
    vnetAddressSpace: '10.3.0.0/22'
    subnetAddressSpace: '10.3.0.0/24' // Only 1 subnet in our spokes
  }
}

output firewallSubnetId string = hubVirtualNetwork.outputs.firewallSubnetId
output spoke001SubnetId string = spoke001VirtualNetwork.outputs.subnetId
output spoke002SubnetId string = spoke002VirtualNetwork.outputs.subnetId
output spoke003SubnetId string = spoke003VirtualNetwork.outputs.subnetId
