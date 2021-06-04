@secure()
param adminPassword string
param prefix string = 'wth128937'
param uri string = 'https://wthstorageiostavri.blob.core.windows.net/staging/install-apache.sh?sp=r&st=2021-06-04T07:48:46Z&se=2021-07-04T15:48:46Z&spr=https&sv=2020-02-10&sr=b&sig=ijQOOAd%2Fh73NUPQqS7i2XTDUCXolsE6%2FRaRBIIRd7GE%3D'

resource secgroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: 'challenge3secgroup'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'Port80'
        properties: {
          description: 'Port80'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Port22'
        properties: {
          description: 'Port22'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'iostavri-vnet-wth'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.1.0/24'
      ]
    }
    subnets: [
      {
        id: 'iostavri-wth-subnet-01'
        name: 'iostavri-wth-subnet-01'
        properties: {
          addressPrefix: '192.168.1.0/26'
          networkSecurityGroup: {
            id: secgroup.id
          }
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${prefix}-publicIP'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${prefix}-nic-01'
  location: resourceGroup().location
  properties:{
    networkSecurityGroup: {
      id: secgroup.id
    }
    ipConfigurations: [
      {
        name: '${prefix}-primary-nic'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  location: resourceGroup().location
  name: '${prefix}-vm'
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    storageProfile: {
      osDisk: {
        osType: 'Linux'
        name: 'OS-Disk'
        createOption: 'FromImage'
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: '${prefix}-vm'
      adminUsername: 'wth-admin'
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
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

resource extWebServer 'Microsoft.Compute/virtualMachines/extensions@2021-03-01'={
  name: '${vm.name}/InstallWebServer'
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion:'2.0'
    autoUpgradeMinorVersion: true
    settings:{
      fileUris:[
        uri
      ]
      commandToExecute: 'sh install-apache.sh'  
    }
  }
}

output out string = adminPassword
