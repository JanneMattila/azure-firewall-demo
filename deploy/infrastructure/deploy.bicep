param location string
param username string
@secure()
param password string

var hubName = 'hub'
var hubVNetName = 'vnet-${hubName}'
var firewallIpAddress = '10.0.1.4'

var spokes = [
  {
    name: 'spoke001'
    vnetAddressSpace: '10.1.0.0/22'
    subnetAddressSpace: '10.1.0.0/24'
  }
  {
    name: 'spoke002'
    vnetAddressSpace: '10.2.0.0/22'
    subnetAddressSpace: '10.2.0.0/24'
  }
  {
    name: 'spoke003'
    vnetAddressSpace: '10.3.0.0/22'
    subnetAddressSpace: '10.3.0.0/24'
  }
]

resource gatewaySubnetRouteTable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: 'rt-${hubName}-gateway'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: spokes[0].name
        properties: {
          addressPrefix: spokes[0].vnetAddressSpace
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
          hasBgpOverride: false
        }
      }
      {
        name: spokes[1].name
        properties: {
          addressPrefix: spokes[1].vnetAddressSpace
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
          hasBgpOverride: false
        }
      }
    ]
  }
}

module hub 'hub/deploy.bicep' = {
  name: 'hub-deployment'
  params: {
    name: hubVNetName
    username: username
    password: password
    gatewaySubnetRouteTableId: gatewaySubnetRouteTable.id
    location: location
  }
}

module spokeDeployments 'spoke/deploy.bicep' = [for spoke in spokes: {
  name: '${spoke.name}-deployment'
  params: {
    spokeName: spoke.name
    hubName: hubVNetName
    hubId: hub.outputs.id
    location: location
    vnetAddressSpace: spoke.vnetAddressSpace
    subnetAddressSpace: spoke.subnetAddressSpace
  }
  dependsOn: [
    hub
  ]
}]

output firewallSubnetId string = hub.outputs.firewallSubnetId
output bastionName string = hub.outputs.bastionName
output virtualMachineResourceId string = hub.outputs.virtualMachineResourceId
