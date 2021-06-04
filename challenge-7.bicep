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

module createVM './challenge-7-module.bicep' = [for i in range(1, 2): {
  name: '${prefix}-VM-${i}'
  params: {
    adminPassword: adminPassword
    prefix: prefix
    uri: uri
    index: '${i}'
    secGroupId: secgroup.id
    subNetId: vnet.properties.subnets[0].id
    lbBackEndPool: loadBalancer.properties.backendAddressPools[0].id
  }
}]

resource publicIPlb 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${prefix}-publicIP-LB'
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

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-02-01' = {
  name: '${prefix}-LB'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        properties: {
          publicIPAddress: {
            id: publicIPlb.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: resourceId('Microsoft.Network/loadBalancers/backendAddressPools','${prefix}-LB','${prefix}-lbBackEndPools')
      }
    ]
  }
}
