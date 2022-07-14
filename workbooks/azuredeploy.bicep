@description('ギャラリーまたは保存リストで使用されているブックのフレンドリ名。この名前は、リソース グループ内で一意である必要があります。')
param workbookDisplayName string = 'FTA - Reliability Workbook'

@description('ブックが表示されるギャラリー。サポートされる値には、ブック、tsg などがあります。通常、これは \'ブック\' です')
param workbookType string = 'workbook'

@description('ブックを関連付けるリソース インスタンスの ID')
param workbookSourceId string = 'azure monitor'

@description('このブック インスタンスの一意の GUID')
param workbookId string = newGuid()

var workbookContent = loadJsonContent('Reliability v2.4.json')

resource workbookId_resource 'microsoft.insights/workbooks@2021-03-08' = {
  name: workbookId
  location: resourceGroup().location
  kind: 'shared'
  properties: {
    displayName: workbookDisplayName
    serializedData: string(workbookContent)
    version: '1.0'
    sourceId: workbookSourceId
    category: workbookType
  }
  dependsOn: []
}

output workbookId string = workbookId_resource.id
