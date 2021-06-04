@secure()
param adminPassword string

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

output out string = adminPassword
tags: {}
  plan: {
    name: 'string'
    publisher: 'string'
    product: 'string'
    promotionCode: 'string'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'string'
    }
    storageProfile: {
      imageReference: {
        id: 'string'
        publisher: 'string'
        offer: 'string'
        sku: 'string'
        version: 'string'
      }
      osDisk: {
        osType: 'string'
        encryptionSettings: {
          diskEncryptionKey: {
            secretUrl: 'string'
            sourceVault: {
              id: 'string'
            }
          }
          keyEncryptionKey: {
            keyUrl: 'string'
            sourceVault: {
              id: 'string'
            }
          }
          enabled: bool
        }
        name: 'string'
        vhd: {
          uri: 'string'
        }
        image: {
          uri: 'string'
        }
        caching: 'string'
        writeAcceleratorEnabled: bool
        diffDiskSettings: {
          option: 'Local'
          placement: 'string'
        }
        createOption: 'string'
        diskSizeGB: int
        managedDisk: {
          id: 'string'
          storageAccountType: 'string'
          diskEncryptionSet: {
            id: 'string'
          }
        }
      }
      dataDisks: [
        {
          lun: int
          name: 'string'
          vhd: {
            uri: 'string'
          }
          image: {
            uri: 'string'
          }
          caching: 'string'
          writeAcceleratorEnabled: bool
          createOption: 'string'
          diskSizeGB: int
          managedDisk: {
            id: 'string'
            storageAccountType: 'string'
            diskEncryptionSet: {
              id: 'string'
            }
          }
          toBeDetached: bool
          detachOption: 'ForceDetach'
        }
      ]
    }
    additionalCapabilities: {
      ultraSSDEnabled: bool
    }
    osProfile: {
      computerName: 'string'
      adminUsername: 'string'
      adminPassword: 'string'
      customData: 'string'
      windowsConfiguration: {
        provisionVMAgent: bool
        enableAutomaticUpdates: bool
        timeZone: 'string'
        additionalUnattendContent: [
          {
            passName: 'OobeSystem'
            componentName: 'Microsoft-Windows-Shell-Setup'
            settingName: 'string'
            content: 'string'
          }
        ]
        patchSettings: {
          patchMode: 'string'
          enableHotpatching: bool
        }
        winRM: {
          listeners: [
            {
              protocol: 'string'
              certificateUrl: 'string'
            }
          ]
        }
      }
      linuxConfiguration: {
        disablePasswordAuthentication: bool
        ssh: {
          publicKeys: [
            {
              path: 'string'
              keyData: 'string'
            }
          ]
        }
        provisionVMAgent: bool
        patchSettings: {
          patchMode: 'string'
        }
      }
      secrets: [
        {
          sourceVault: {
            id: 'string'
          }
          vaultCertificates: [
            {
              certificateUrl: 'string'
              certificateStore: 'string'
            }
          ]
        }
      ]
      allowExtensionOperations: bool
      requireGuestProvisionSignal: bool
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: 'string'
          properties: {
            primary: bool
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: bool
        vTpmEnabled: bool
      }
      encryptionAtHost: bool
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: bool
        storageUri: 'string'
      }
    }
    availabilitySet: {
      id: 'string'
    }
    virtualMachineScaleSet: {
      id: 'string'
    }
    proximityPlacementGroup: {
      id: 'string'
    }
    priority: 'string'
    evictionPolicy: 'string'
    billingProfile: {
      maxPrice: any('number')
    }
    host: {
      id: 'string'
    }
    hostGroup: {
      id: 'string'
    }
    licenseType: 'string'
    extensionsTimeBudget: 'string'
    platformFaultDomain: int
  }
  identity: {
    type: 'string'
    userAssignedIdentities: {}
  }
  zones: [
    'string'
  ]
  extendedLocation: {
    name: 'string'
    type: 'EdgeZone'
  }
  resources: []
