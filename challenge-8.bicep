@secure()
param adminPassword string
param prefix string = 'wth128937'
param uri string = 'https://wthstorageiostavri.blob.core.windows.net/staging/install-apache.sh?sp=r&st=2021-06-04T07:48:46Z&se=2021-07-04T15:48:46Z&spr=https&sv=2020-02-10&sr=b&sig=ijQOOAd%2Fh73NUPQqS7i2XTDUCXolsE6%2FRaRBIIRd7GE%3D'

var lbName = '${prefix}-LB'

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
          natGateway: {
            id: natgateway.id
          }
        }
      }
    ]
  }
}

module createVM './challenge-8-module.bicep' = [for i in range(1, 2): {
  name: '${prefix}-VM-${i}'
  params: {
    adminPassword: adminPassword
    prefix: prefix
    uri: uri
    index: i
    secGroupId: secgroup.id
    subNetId: vnet.properties.subnets[0].id
    lbBackEndPool: loadBalancer.properties.backendAddressPools[0].id
    lbName: lbName
  }
}]

resource publicIPlb 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${prefix}-publicIP-LB'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource publicIPGW 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${prefix}-publicIP-GW'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-02-01' = {
  name: lbName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'lbFrontEnd'
        properties: {
          publicIPAddress:{
            id: publicIPlb.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'LoadBalancerBackendPool'
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRules'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', lbName, 'lbFrontEnd')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBackendPool')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'probe01')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 5
        }
    }
    ]
    probes: [
      {
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 10
          numberOfProbes: 2
        }
        name: 'probe01'
      }
    ]
    // inboundNatRules: [
    //   {
    //     name: 'Test'
    //     properties: {
    //       frontendIPConfiguration: {
    //         id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', lbName, 'lbFrontEnd')
    //       }

    //       frontendPort: 20022
    //       backendPort: 22
    //       enableFloatingIP: false
    //       idleTimeoutInMinutes: 4
    //       protocol: 'Tcp'

    //       enableTcpReset: false
    //     }
    //   }
    //   {
    //     name: 'Test2'
    //     properties: {
    //       frontendIPConfiguration: {
    //         id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', lbName, 'lbFrontEnd')
    //       }

    //       frontendPort: 20023
    //       backendPort: 22
    //       enableFloatingIP: false
    //       idleTimeoutInMinutes: 4
    //       protocol: 'Tcp'

    //       enableTcpReset: false
    //     }
    //   }
  //]
  }
}

resource natgateway 'Microsoft.Network/natGateways@2020-05-01' = {
  name: '${prefix}-NGW'
  location: resourceGroup().location
  tags: {}
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 5
    publicIpAddresses: [
      {
        id: publicIPGW.id
      }
    ]
  }
}
