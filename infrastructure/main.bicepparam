using './main.bicep'

param location = 'eastus'
param acrName = 'acrwizexercise12345'
param storageAccountName = 'stwizexercise12345'
param sshPublicKey = readEnvironmentVariable('SSH_PUBLIC_KEY')
