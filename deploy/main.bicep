param username string
@secure()
param password string
param location string = resourceGroup().location

var hubName = 'hub'
var hubVNetName = 'vnet-${hubName}'
var firewallIpAddress = '10.0.1.4'
var all = '0.0.0.0/0'

var spokes = [
  {
    name: 'spoke001'
    vnetAddressSpace: '10.1.0.0/22'
    subnetAddressSpace: '10.1.0.0/24'
    privateIPAddress: '10.1.0.4'
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
  }
  {
    name: 'spoke002'
    vnetAddressSpace: '10.2.0.0/22'
    subnetAddressSpace: '10.2.0.0/24'
    privateIPAddress: '10.2.0.4'
    imageReference: {
      publisher: 'canonical'
      offer: 'ubuntu-24_04-lts'
      sku: 'server'
      version: 'latest'
    }
  }
  {
    name: 'spoke003'
    vnetAddressSpace: '10.3.0.0/22'
    subnetAddressSpace: '10.3.0.0/24'
    privateIPAddress: '10.3.0.4'
    imageReference: {
      publisher: 'canonical'
      offer: 'ubuntu-24_04-lts'
      sku: 'server'
      version: 'latest'
    }
  }
]

// All route tables are defined here
resource hubGatewaySubnetRouteTable 'Microsoft.Network/routeTables@2024-05-01' = {
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
        }
      }
      {
        name: spokes[1].name
        properties: {
          addressPrefix: spokes[1].vnetAddressSpace
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
        }
      }
      {
        name: spokes[2].name
        properties: {
          addressPrefix: spokes[2].vnetAddressSpace
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
        }
      }
    ]
  }
}


resource spoke1RouteTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-${spokes[0].name}-front'
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'All'
        properties: {
          addressPrefix: all
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
        }
      }
    ]
  }
}

resource spoke2RouteTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-${spokes[1].name}-front'
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'All'
        properties: {
          addressPrefix: all
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
        }
      }
    ]
  }
}

resource spoke3RouteTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-${spokes[2].name}-front'
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: spokes[0].name
        properties: {
          addressPrefix: spokes[0].vnetAddressSpace
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIpAddress
        }
      }
    ]
  }
}

var spokeRouteTables = [
  {
    id: spoke1RouteTable.id
  }
  {
    id: spoke2RouteTable.id
  }
  {
    id: spoke3RouteTable.id
  }
]

module hub 'infrastructure/hub/deploy.bicep' = {
  name: 'hub-deployment'
  params: {
    name: hubVNetName
    username: username
    password: password
    gatewaySubnetRouteTableId: hubGatewaySubnetRouteTable.id
    location: location
  }
}

module firewall 'firewall/deploy.bicep' = {
  name: 'firewall-resources-deployment'
  params: {
    firewallSubnetId: hub.outputs.firewallSubnetId
    location: location
  }
}

module spokeDeployments 'infrastructure/spoke/deploy.bicep' = [
  for (spoke, i) in spokes: {
    name: '${spoke.name}-deployment'
    params: {
      spokeName: spoke.name
      hubName: hubVNetName
      hubId: hub.outputs.id
      location: location
      vnetAddressSpace: spoke.vnetAddressSpace
      subnetAddressSpace: spoke.subnetAddressSpace
      firewallIpAddress: firewall.outputs.firewallPrivateIp
      routeTableId: spokeRouteTables[i].id
      privateIPAddress: spoke.privateIPAddress
      imageReference: spoke.imageReference
      username: username
      password: password
    }
  }
]

module storage 'storage.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: 'stspoke001${uniqueString(resourceGroup().id)}'
    vnetId: hub.outputs.id
    privateEndpointSubnetId: spokeDeployments[0].outputs.subnetId
    location: location
  }
}

output firewallPrivateIp string = firewall.outputs.firewallPrivateIp
output firewallSubnetId string = hub.outputs.firewallSubnetId
output bastionName string = hub.outputs.bastionName
output virtualMachineResourceId string = hub.outputs.virtualMachineResourceId
output spoke1VirtualMachineResourceId string = spokeDeployments[0].outputs.vmResourceId
output spoke2VirtualMachineResourceId string = spokeDeployments[1].outputs.vmResourceId
output spoke3VirtualMachineResourceId string = spokeDeployments[2].outputs.vmResourceId
output storage string = storage.outputs.storage
output storageConnectionString string = storage.outputs.storageConnectionString
output logAnalyticsWorkspaceCustomerId string = firewall.outputs.logAnalyticsWorkspaceCustomerId
