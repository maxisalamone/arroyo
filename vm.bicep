resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: 'ArroyoVM'
  location: 'your_location_here'
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: 'myVM'
      adminUsername: 'ArroyoVM'
      adminPassword: 'FirstPass'
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

resource lock 'Microsoft.Authorization/locks@2016-09-01' = {
  name: 'vmLock'
  properties: {
    level: 'CanNotDelete'
    notes: 'Lock to prevent accidental deletion of the VM'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-07-01' = {
  name: 'myNIC'
  location: 'your_location_here'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/publicIPAddresses/{publicIpName}'
          }
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-07-01' = {
  name: 'myPublicIP'
  location: 'your_location_here'
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

output vmName string = vm.name
output vmPublicIP string = publicIp.properties.ipAddress
