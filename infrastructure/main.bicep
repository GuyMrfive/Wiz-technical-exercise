targetScope = 'resourceGroup'

param location string = resourceGroup().location
param prefix string = 'wiz'

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
    prefix: prefix
  }
}

module aks './modules/aks.bicep' = {
  name: 'aks-deployment'
  params: {
    location: location
    prefix: prefix
    subnetId: network.outputs.aksSubnetId
  }
}

module vm './modules/vm.bicep' = {
  name: 'vm-deployment'
  params: {
    location: location
    prefix: prefix
    subnetId: network.outputs.dbSubnetId
  }
}

module storage './modules/storage.bicep' = {
  name: 'storage-deployment'
  params: {
    location: location
    prefix: prefix
  }
}

output aksName string = aks.outputs.name
output acrLoginServer string = acr.outputs.loginServer
output mongoPrivateIp string = vm.outputs.privateIp
