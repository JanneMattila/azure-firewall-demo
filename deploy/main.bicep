param username string
@secure()
param password string
param location string = resourceGroup().location

module infrastructure 'infrastructure/deploy.bicep' = {
  name: 'infra-deployment'
  params: {
    username: username
    password: password
    location: location
  }
}

module firewall 'firewall/deploy.bicep' = {
  name: 'firewall-resources-deployment'
  params: {
    firewallSubnetId: infrastructure.outputs.firewallSubnetId
    location: location
  }
}

output firewallPrivateIp string = firewall.outputs.firewallPrivateIp
output bastionName string = infrastructure.outputs.bastionName
output virtualMachineResourceId string = infrastructure.outputs.virtualMachineResourceId
