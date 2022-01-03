param parentName string

module common '1-common/common.bicep' = {
  name: 'rcg-common-deployment'
  params: {
    parentName: parentName
  }
}

module vnet '2-vnet/vnet.bicep' = {
  name: 'rcg-vnet-deployment'
  params: {
    parentName: parentName
  }
  dependsOn: [
    common
  ]
}

module onPremises '3-on-premises/on-premises.bicep' = {
  name: 'rcg-on-premises-deployment'
  params: {
    parentName: parentName
  }
  dependsOn: [
    vnet
  ]
}

module spokes '4-spoke/deploy.bicep' = {
  name: 'rcg-spokes-deployment'
  params: {
    parentName: parentName
  }
  dependsOn: [
    onPremises
  ]
}
