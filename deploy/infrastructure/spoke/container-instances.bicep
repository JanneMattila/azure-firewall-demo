param name string
param subnetId string
param location string

resource aci 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: name
  location: location
  properties: {
    containers: [
      {
        name: 'webapp-network-tester'
        properties: {
          // From Docker Hub:
          // https://hub.docker.com/r/jannemattila/webapp-network-tester
          // image: 'jannemattila/webapp-network-tester:1.0.76'
          // However, since ACI is quite frequently failing to pull images from Docker Hub,
          // I have pushed the image to my Azure Container Registry:
          image: 'jannemattila.azurecr.io/webapp-network-tester:1.0.76'
          environmentVariables: [
            {
              name: 'ASPNETCORE_HTTP_PORTS'
              value: '80'
            }
          ]
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
      type: 'Private'
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
    }
    subnetIds: [
      {
        id: subnetId
      }
    ]
  }
}
