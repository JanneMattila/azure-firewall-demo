param parentName string

module common '1-common/common.bicep' = {
  name: 'rcg-common-deployment'
  params: {
    parentName: parentName
  }
}

module hub '2-hub/hub.bicep' = {
  name: 'rcg-hub-deployment'
  params: {
    parentName: parentName
  }
  dependsOn: [
    common
  ]
}

module vnet '3-vnet/vnet.bicep' = {
  name: 'rcg-vnet-deployment'
  params: {
    parentName: parentName
  }
  dependsOn: [
    hub
  ]
}

module onPremises '4-on-premises/on-premises.bicep' = {
  name: 'rcg-on-premises-deployment'
  params: {
    parentName: parentName
  }
  dependsOn: [
    vnet
  ]
}

module spokes '5-spoke/spokes.bicep' = {
  name: 'rcg-spokes-deployment'
  params: {
    parentName: parentName
  }
  dependsOn: [
    onPremises
  ]
}
