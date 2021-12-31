param location string
param username string
@secure()
param password string

var hubName = 'vnet-hub'
var spoke001 = 'vnet-spoke001'
var spoke002 = 'vnet-spoke002'
var spoke003 = 'vnet-spoke003'

var spoke001Name = 'vnet-${spoke001}'
var spoke002Name = 'vnet-${spoke002}'
var spoke003Name = 'vnet-${spoke003}'

// Hub subnets are defined inside module
module hubVirtualNetwork 'hub-virtual-network.bicep' = {
  name: 'hub-deployment'
  params: {
    name: hubName
    location: location
  }
}

module vpn 'vpn.bicep' = {
  name: 'vpn-deployment'
  params: {
    name: 'vgw-vpn'
    location: location
    subnetId: hubVirtualNetwork.outputs.gatewaySubnetId
  }
}

module bastion 'bastion.bicep' = {
  name: 'bastion-deployment'
  params: {
    name: 'bas-management'
    location: location
    subnetId: hubVirtualNetwork.outputs.bastionSubnetId
  }
}

module jumpbox 'jumpbox.bicep' = {
  name: 'jumpbox-deployment'
  params: {
    name: 'jumpbox'
    username: username
    password: password
    location: location
    subnetId: hubVirtualNetwork.outputs.managementSubnetId
  }
}

module spoke001VirtualNetwork 'spoke-virtual-network.bicep' = {
  name: '${spoke001}-deployment'
  params: {
    name: spoke001Name
    tag: spoke001
    hubName: hubName
    hubId: hubVirtualNetwork.outputs.id
    location: location
    vnetAddressSpace: '10.1.0.0/22'
    subnetAddressSpace: '10.1.0.0/24' // Only 1 subnet in our spokes
  }
  dependsOn: [
    vpn
  ]
}

module aciSpoke001 'container-instances.bicep' = {
  name: '${spoke001}-aci-deployment'
  params: {
    name: 'ci-${spoke001}'
    location: location
    subnetId: spoke001VirtualNetwork.outputs.subnetId
  }
}

module spoke002VirtualNetwork 'spoke-virtual-network.bicep' = {
  name: '${spoke002}-deployment'
  params: {
    name: spoke002Name
    tag: spoke002
    hubName: hubName
    hubId: hubVirtualNetwork.outputs.id
    location: location
    vnetAddressSpace: '10.2.0.0/22'
    subnetAddressSpace: '10.2.0.0/24' // Only 1 subnet in our spokes
  }
  dependsOn: [
    vpn
  ]
}

module aciSpoke002 'container-instances.bicep' = {
  name: '${spoke002}-aci-deployment'
  params: {
    name: 'ci-${spoke002}'
    location: location
    subnetId: spoke002VirtualNetwork.outputs.subnetId
  }
}

module spoke003VirtualNetwork 'spoke-virtual-network.bicep' = {
  name: '${spoke003}-deployment'
  params: {
    name: spoke003Name
    tag: spoke003
    hubName: hubName
    hubId: hubVirtualNetwork.outputs.id
    location: location
    vnetAddressSpace: '10.3.0.0/22'
    subnetAddressSpace: '10.3.0.0/24' // Only 1 subnet in our spokes
  }
  dependsOn: [
    vpn
  ]
}

module aciSpoke003 'container-instances.bicep' = {
  name: '${spoke003}-aci-deployment'
  params: {
    name: 'ci-${spoke003}'
    location: location
    subnetId: spoke003VirtualNetwork.outputs.subnetId
  }
}

output firewallSubnetId string = hubVirtualNetwork.outputs.firewallSubnetId
output spoke001SubnetId string = spoke001VirtualNetwork.outputs.subnetId
output spoke002SubnetId string = spoke002VirtualNetwork.outputs.subnetId
output spoke003SubnetId string = spoke003VirtualNetwork.outputs.subnetId
