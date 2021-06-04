resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'iostavri-vnet-wth'
  location: resourceGroup().location
  properties:{
    addressSpace:{
      addressPrefixes:[
        '192.168.1.0/24'
      ]
    }
    subnets:[
      {
        id: 'iostavri-wth-subnet-01'
        name: 'iostavri-wth-subnet-01'
        properties:{
          addressPrefix: '192.168.1.0/26'
        }
      }
    ]
  }
}
