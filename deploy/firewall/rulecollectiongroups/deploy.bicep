param parentName string

module common '1-common/common.bicep' = {
  name: 'rcg-common-deployment'
  params: {
    name: 'Common'
    parentName: parentName
  }
}

module vnet '2-vnet/vnet.bicep' = {
  name: 'rcg-vnet-deployment'
  params: {
    name: 'VNET'
    parentName: parentName
  }
  dependsOn: [
    common
  ]
}
