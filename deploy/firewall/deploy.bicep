param name string = 'afw-hub'
param location string
param firewallSubnetId string

module firewallPolicy 'firewall-policy.bicep' = {
  name: 'firewallPolicy-deployment'
  params: {
    location: location
    name: 'afwp-hub'
    tier: 'Standard'
  }
}

module publicIp 'public-ip.bicep' = {
  name: 'firewall-pip-deployment'
  params: {
    name: 'pip-firewall'
  }
}

module firewall 'firewall.bicep' = {
  name: 'firewall-deployment'
  params: {
    name: name
    location: location
    skuName: 'AZFW_VNet'
    skuTier: 'Standard'
    firewallPolicyId: firewallPolicy.outputs.id
    ip: {
      publicIp: publicIp.outputs.id
      subnet: firewallSubnetId
    }
  }
}

output firewallPrivateIp string = firewall.outputs.privateIPAddress
