param location string
param user string
param pass string

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: ArroyoSecGroup
  location: location
  properties: {
    securityRules: [
      // Allow HTTP traffic (port 80)
      {
        name: 'allow-http'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '80'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      },
      // Allow HTTPS traffic (port 443)
      {
        name: 'allow-https'
        properties: {
          priority: 101
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      },
      // Allow SQL Server traffic (port 1433)
      {
        name: 'allow-sql-server'
        properties: {
          priority: 102
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '1433'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      },
      // Allow Remote Desktop Protocol traffic (port 3389)
      {
        name: 'allow-rdp'
        properties: {
          priority: 103
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      },
      // Allow all outbound traffic
      {
        name: 'allow-outbound'
        properties: {
          priority: 200
          access: 'Allow'
          direction: 'Outbound'
          destinationPortRange: '*'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
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
          id: nic.id
          properties: {
            deleteOption: 'Detach'
            primary: true
          }
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

output vmName string = vm.name
output vmPublicIP string = publicIp.properties.ipAddress
