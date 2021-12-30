param location string = resourceGroup().location

module virtualNetworks 'network/virtual-networks.bicep' = {
  name: 'virtual-networks-deployment'
  params: {
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
