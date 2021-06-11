@secure()
param adminPassword string
param prefix string
param uri string
param index int
param secGroupId string
param subNetId string
param lbBackEndPool string
param lbName string

/*resource publicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${prefix}-publicIP-${index}'
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
*/

resource inboundNatRule 'Microsoft.Network/loadBalancers/inboundNatRules@2020-07-01' = {
  name: '${lbName}/name${index}'
  properties: {
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', lbName, 'lbFrontEnd')
    }
    protocol: 'Tcp'
    frontendPort: 20020+index
    backendPort: 22
    idleTimeoutInMinutes: 4
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${prefix}-nic-${index}'
  location: resourceGroup().location
  properties:{
    networkSecurityGroup: {
      id: secGroupId
    }
    ipConfigurations: [
      {
        name: '${prefix}-primary-nic-${index}'
        properties: {
          subnet: {
            id: subNetId
          }
  //        publicIPAddress: {
  //          id: publicIP.id
  //        }
          loadBalancerBackendAddressPools: [
            {
              id: lbBackEndPool
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: inboundNatRule.id
            }
          ]          
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  location: resourceGroup().location
  name: '${prefix}-vm-${index}'
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    storageProfile: {
      osDisk: {
        osType: 'Linux'
        name: 'OS-Disk-${index}'
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
      computerName: '${prefix}-vm-${index}'
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
