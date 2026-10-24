param location string = resourceGroup().location
param workspaceName string = 'law-wiz-exercise'

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}



output workspaceId string = law.id
output workspaceName string = law.name
