//-------------------------------------------
// Storage tab
//-------------------------------------------
locals {
  kql_storage_account_resources_details = templatefile(
    "${path.module}/template_kql/storage/storage_account_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  workbook_storage_json = templatefile("${path.module}/templates/storage.tpl.json", {
    "kql_storage_account_resources_details" = jsonencode(local.kql_storage_account_resources_details)

  })
}
resource "random_uuid" "workbook_name_storage" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-storage"
  }
}

resource "azurerm_application_insights_workbook" "storage" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_storage.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-storage"
  data_json           = local.workbook_storage_json
}

resource "local_file" "storage" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookStorage.workbook"
  content  = local.workbook_storage_json
}
