param location string
param username string
@secure()
param password string

var hubName = 'hub'
var hubVNetName = 'vnet-${hubName}'
var firewallIpAddress = '10.0.1.4'
var spoke001 = 'spoke001'
var spoke002 = 'spoke002'
var spoke003 = 'spoke003'
var bastionName = 'bas-management'

var spoke001VNetName = 'vnet-${spoke001}'
var spoke002VNetName = 'vnet-${spoke002}'
var spoke003VNetName = 'vnet-${spoke003}'

var spoke001VNetAddressSpace = '10.1.0.0/22'
var spoke002VNetAddressSpace = '10.2.0.0/22'
var spoke003VNetAddressSpace = '10.3.0.0/22'
var spoke001SubnetAddressSpace = '10.1.0.0/24'
var spoke002SubnetAddressSpace = '10.2.0.0/24'
var spoke003SubnetAddressSpace = '10.3.0.0/24'

resource gatewaySubnetRouteTable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: 'rt-${hubName}-gateway'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: spoke001VNetName
        properties: {
          addressPrefix: spoke001SubnetAddressSpace
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
          hasBgpOverride: false
        }
      }
      {
        name: spoke002VNetName
        properties: {
          addressPrefix: spoke002SubnetAddressSpace
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
          hasBgpOverride: false
        }
      }
    ]
  }
}

// Hub subnets are defined inside module
module hubVirtualNetwork 'hub-virtual-network.bicep' = {
  name: 'hub-deployment'
  params: {
    name: hubVNetName
    gatewaySubnetRouteTableId: gatewaySubnetRouteTable.id
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
    name: bastionName
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
    name: spoke001VNetName
    tag: spoke001
    hubName: hubVNetName
    hubId: hubVirtualNetwork.outputs.id
    location: location
    vnetAddressSpace: spoke001VNetAddressSpace
    subnetAddressSpace: spoke001SubnetAddressSpace // Only 1 subnet in our spokes
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
    name: spoke002VNetName
    tag: spoke002
    hubName: hubVNetName
    hubId: hubVirtualNetwork.outputs.id
    location: location
    vnetAddressSpace: spoke002VNetAddressSpace
    subnetAddressSpace: spoke002SubnetAddressSpace // Only 1 subnet in our spokes
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
    name: spoke003VNetName
    tag: spoke003
    hubName: hubVNetName
    hubId: hubVirtualNetwork.outputs.id
    location: location
    vnetAddressSpace: spoke003VNetAddressSpace
    subnetAddressSpace: spoke003SubnetAddressSpace // Only 1 subnet in our spokes
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

output bastionName string = bastionName
output virtualMachineResourceId string = jumpbox.outputs.virtualMachineResourceId
