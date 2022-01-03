param username string
@secure()
param password string
param location string = resourceGroup().location

module virtualNetworks 'network/virtual-networks.bicep' = {
  name: 'virtual-networks-deployment'
  params: {
    username: username
    password: password
    location: location
  }
}

module firewall 'firewall/deploy.bicep' = {
  name: 'firewall-resources-deployment'
  params: {
    firewallSubnetId: virtualNetworks.outputs.firewallSubnetId
    location: location
  }
}

output virtualNetworks object = virtualNetworks
output firewallPrivateIp string = firewall.outputs.firewallPrivateIp
output bastionName string = virtualNetworks.outputs.bastionName
output virtualMachineResourceId string = virtualNetworks.outputs.virtualMachineResourceId
