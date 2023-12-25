//-------------------------------------------
// Resiliency Scenarios tab
//-------------------------------------------
locals {
  workbook_resiliencyscenarios_json = templatefile("${path.module}/templates/crossregionreplication.workbook", {

  })
}
resource "random_uuid" "workbook_name_resiliencyscenarios" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-resiliencyscenarios"
  }
}

resource "azurerm_application_insights_workbook" "resiliencyscenarios" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_resiliencyscenarios.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-resiliencyscenarios"
  data_json           = local.workbook_resiliencyscenarios_json
}

resource "local_file" "resiliencyscenarios" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookResiliencyScenarios.workbook"
  content  = local.workbook_resiliencyscenarios_json
}
