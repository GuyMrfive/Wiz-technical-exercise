targetScope = 'resourceGroup'

param location string = resourceGroup().location
param prefix string = 'wiz'
param acrName string //Globally unique container registry name
param sshPublicKey string
param storageAccountName string

module network './modules/network.bicep' = {
  name: 'network-deployment'
  params: {
    location: location
    prefix: prefix
  }
}

module acr './modules/acr.bicep' = {
  name: 'acr-deployment'
  params: {
    location: location
    acrName: acrName
  }
}

module aks './modules/aks.bicep' = {
    name: 'aks-deployment'
    params: {
      location: location
      prefix: prefix
      subnetId: network.outputs.aksSubnetId
      acrId: acr.outputs.id
    }
  }

  
  module vm './modules/vm.bicep' = {
    name: 'mongodb-vm-deployment'
    params: {
      location: location
      prefix: prefix
      subnetId: network.outputs.dbSubnetId
      sshPublicKey: sshPublicKey
    }
  }

  
  module storage './modules/storage.bicep' = {
    name: 'storage-deployment'
    params: {
      location: location
      storageAccountName: storageAccountName
    }
  }
  


output aksName string = aks.outputs.name
output acrLoginServer string = acr.outputs.loginServer
output acrId string = acr.outputs.id
output mongoVmPublicIp string = vm.outputs.publicIpAddress
output mongoVmPrivateIp string = vm.outputs.privateIpAddress
output mongoVmPrincipalId string = vm.outputs.vmPrincipalId
output backupStorageName string = storage.outputs.storageAccountName
output backupBlobEndpoint string = storage.outputs.blobEndpoint
output backupContainerName string = storage.outputs.containerName
