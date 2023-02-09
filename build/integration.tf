//-------------------------------------------
// Integration tab
//-------------------------------------------
locals {
  kql_integration_apim_resources_details = templatefile(
    "${path.module}/template_kql/integration/integration_apim_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  workbook_integration_json = templatefile("${path.module}/templates/integration.tpl.json", {
    "kql_integration_apim_resources_details" = jsonencode(local.kql_integration_apim_resources_details)
  })
}
resource "random_uuid" "workbook_name_integration" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-integration"
  }
}

resource "azurerm_application_insights_workbook" "integration" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_integration.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-integration"
  data_json           = local.workbook_integration_json
}

resource "local_file" "integration" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookIntegration.workbook"
  content  = local.workbook_integration_json
}
