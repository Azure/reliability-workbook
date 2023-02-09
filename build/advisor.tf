//-------------------------------------------
// Azure Advisor tab
//-------------------------------------------

locals {
  workbook_advisor_json = templatefile("${path.module}/templates/advisor.tpl.json", {
    "kql_advisor_resource" = jsonencode(local.kql_advisor_resource)
  })
}
resource "random_uuid" "workbook_name_advisor" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-advisor"
  }
}

resource "azurerm_application_insights_workbook" "advisor" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_advisor.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-advisor"
  data_json           = local.workbook_advisor_json
}

resource "local_file" "advisor" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookAdvisor.workbook"
  content  = local.workbook_advisor_json
}
