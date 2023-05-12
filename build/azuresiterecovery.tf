//-------------------------------------------
// Azure Site Recovery tab
//-------------------------------------------

locals {
  kql_azuresiterecovery_resources_details = templatefile("${path.module}/template_kql/azuresiterecovery/azuresiterecovery_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  workbook_azuresiterecovery_json = templatefile("${path.module}/templates/azuresiterecovery.tpl.json", {
    "kql_azuresiterecovery_resources_details" = jsonencode(local.kql_azuresiterecovery_resources_details)
  })
}
resource "random_uuid" "workbook_name_azuresiterecovery" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-azuresiterecovery"
  }
}

resource "azurerm_application_insights_workbook" "azuresiterecovery" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_azuresiterecovery.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-azuresiterecovery"
  data_json           = local.workbook_azuresiterecovery_json
}

resource "local_file" "azuresiterecovery" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookAzureSiteRecovery.workbook"
  content  = local.workbook_azuresiterecovery_json
}
