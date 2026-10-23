
param location string = resourceGroup().location
param prefix string = 'wiz'

@description('Subnet ID from network.bicep')
param subnetId string

@description('ACR resource ID from acr.bicep')
param acrId string

resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: 'aks-${prefix}-exercise'
  location: location

  sku: {
    name: 'Base'
    tier: 'Free'
  }

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    dnsPrefix: 'aks-${prefix}-exercise'

    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 2
        vmSize: 'Standard_D2s_v5'
        mode: 'System'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
        osDiskSizeGB: 32
      }
    ]

    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      podCidr: '192.168.0.0/16'
      serviceCidr: '10.1.0.0/16'
      dnsServiceIP: '10.1.0.10'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
  }
}

output name string = aks.name
output id string = aks.id
