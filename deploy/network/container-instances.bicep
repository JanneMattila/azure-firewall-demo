param name string
param subnetId string
param location string

resource aci 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: name
  location: location
  properties: {
    networkProfile: {
      id: subnetId
    }
    containers: [
      {
        name: 'webapp-network-tester'
        properties: {
          image: 'jannemattila/webapp-network-tester:latest'
          ports: [
            {
              port: 80
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }
    ]
    restartPolicy: 'OnFailure'
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
    }
  }
}
