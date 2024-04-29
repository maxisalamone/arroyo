param location string
param user string
param pass string

resource vm 'Microsoft.Compute/virtualMachines@2023-11-01' = {
  name: 'ArroyoVM'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: 'ArroyoVM'
      adminUsername: user
      adminPassword: pass
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          lun: 0
          createOption: 'Empty'
          diskSizeGB: 128
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkInterfaces/{nicName}'
        }
      ]
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: ArroyoNW
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource lock 'Microsoft.Authorization/locks@2016-09-01' = {
  name: 'vmLock'
  properties: {
    level: 'CanNotDelete'
    notes: 'Lock to prevent accidental deletion of the VM'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: 'ArroyoNIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
        }
      }
    ]
  }
  dependsOn: [virtualNetwork]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-07-01' = {
  name: 'ArroyoPublicIP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

output vmName string = vm.name
output vmPublicIP string = publicIp.properties.ipAddress
