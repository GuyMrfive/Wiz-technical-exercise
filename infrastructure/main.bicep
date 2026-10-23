targetScope = 'resourceGroup'

param location string = resourceGroup().location
param prefix string = 'wiz'
param acrName string 
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

  var blobContributorRoleId = subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  )
  
  resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
    name: storageAccountName
  }
  
  resource vmBackupRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    name: guid(resourceGroup().id, principalId, roleDefinitionId)
    scope: storageAccount
    properties: {
      roleDefinitionId: blobContributorRoleId
      principalId: vm.outputs.vmPrincipalId
      principalType: 'ServicePrincipal'
    }
    dependsOn: [
      storage
    ]
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
