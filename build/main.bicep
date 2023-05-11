param location string = resourceGroup().location
param name string
param serializedData string

resource workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid(name)
  location: location
  kind: 'shared'
  properties: {
    category: 'workbook'
    sourceId: 'Azure Monitor'
    displayName: name
    version: '1.0'
    serializedData: serializedData
  }
}

output resource_id string = workbook.id
