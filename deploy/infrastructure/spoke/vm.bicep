param name string
param location string
param subnetId string
param privateIPAddress string
param imageReference object
param username string
@secure()
param password string
param forceUpdateTag string = utcNow()

resource nic 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: 'nic-${name}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: privateIPAddress
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: name
      adminUsername: username
      adminPassword: password
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: 'vm_${name}OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: 256
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// resource vmInstall 'Microsoft.Compute/virtualMachines/runCommands@2023-07-01' = {
//   name: 'vm-install-${name}'
//   location: location
//   parent: vm
//   properties: {
//     treatFailureAsDeploymentFailure: true
//     source: {
//       script: script
//     }
//   }
// }

resource vmExtensionWindows 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = if (imageReference.publisher == 'MicrosoftWindowsServer') {
  name: '${name}-CustomScriptExtensionWindows'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    forceUpdateTag: forceUpdateTag
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/JanneMattila/azure-firewall-demo/refs/heads/main/deploy/infrastructure/spoke/install-windows.ps1'
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File install-windows.ps1'
    }
  }
}


resource vmExtensionLinux 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = if (imageReference.publisher != 'MicrosoftWindowsServer') {
  name: '${name}-CustomScriptExtensionLinux'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    forceUpdateTag: forceUpdateTag
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/JanneMattila/azure-firewall-demo/refs/heads/main/deploy/infrastructure/spoke/install-linux.sh'
      ]
      commandToExecute: 'bash install-linux.sh'
    }
  }
}

output vmResourceId string = vm.id
output vmPrivateIP string = nic.properties.ipConfigurations[0].properties.privateIPAddress
