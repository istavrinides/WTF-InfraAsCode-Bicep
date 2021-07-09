@secure()
param adminPassword string
param prefix string
param uri string
param subNetId string
param lbBackEndPoolId string
param lbProbeId string
param lbInboundNatPoolId string


resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2019-03-01' = {
  name: '${prefix}-vmss'
  location: resourceGroup().location
  sku: {
    name: 'Standard_D2_v3'
    tier: 'Standard'
    capacity: 2
  }
  properties: {
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: '${prefix}-vm-'
        adminUsername: 'wth-admin'
        adminPassword: adminPassword
        linuxConfiguration: {
          disablePasswordAuthentication: false
          provisionVMAgent: true
        }
      }
      storageProfile: {
        imageReference: {
          publisher: 'Canonical'
          offer: 'UbuntuServer'
          sku: '18.04-LTS'
          version: 'latest'
        }
        osDisk: {
          writeAcceleratorEnabled: false
          createOption: 'FromImage'
          diskSizeGB: 50
          osType: 'Linux'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
        }
      }
      networkProfile: {
        healthProbe: {
          id: lbProbeId
        }
        networkInterfaceConfigurations: [
          {
            name: 'vmss-vm-nic'
            properties: {
              primary: true
              enableAcceleratedNetworking: false
              ipConfigurations: [
                {
                  name: 'vmss-vm-nic-ipc'
                  properties: {
                    subnet: {
                      id: subNetId
                    }
                    primary: true
                    privateIPAddressVersion: 'IPv4'
                    loadBalancerBackendAddressPools: [
                      {
                        id: lbBackEndPoolId
                      }
                    ]
                    loadBalancerInboundNatPools: [
                      {
                        id: lbInboundNatPoolId
                      }
                    ]
                  }
                }
              ]
              enableIPForwarding: false
            }
          }
        ]
      }
      extensionProfile: {
        extensions: [
          {
            name: 'vmss-extention'
            properties: {
              publisher: 'Microsoft.Azure.Extensions'
              type: 'CustomScript'
              typeHandlerVersion: '2.0'
              autoUpgradeMinorVersion: true
              settings: {
                fileUris:[
                  uri
                ]
                commandToExecute: 'sh install-apache.sh'  
              }
            }
          }
        ]
      }
      priority: 'Spot'
      evictionPolicy: 'Delete'
    }
    overprovision: false
    singlePlacementGroup: false
    upgradePolicy: {
      mode:  'Manual'
    } 
  }
}
