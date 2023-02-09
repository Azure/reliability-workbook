//-------------------------------------------
// Web tab
//-------------------------------------------
locals {
  kql_webapp_appsvc_resources_details = templatefile(
    "${path.module}/template_kql/webapp/webapp_appsvc_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_webapp_appsvcplan_resources_details = templatefile(
    "${path.module}/template_kql/webapp/webapp_appsvcplan_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_webapp_appservice_funcapp_resources_details = templatefile(
    "${path.module}/template_kql/webapp/webapp_appservice_funcapp_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  workbook_web_json = templatefile("${path.module}/templates/web.tpl.json", {
    "kql_webapp_appsvc_resources_details"             = jsonencode(local.kql_webapp_appsvc_resources_details)
    "kql_webapp_appsvcplan_resources_details"         = jsonencode(local.kql_webapp_appsvcplan_resources_details)
    "kql_webapp_appservice_funcapp_resources_details" = jsonencode(local.kql_webapp_appservice_funcapp_resources_details)
  })
}
resource "random_uuid" "workbook_name_web" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-web"
  }
}

resource "azurerm_application_insights_workbook" "web" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_web.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-web"
  data_json           = local.workbook_web_json
}

resource "local_file" "web" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookWeb.workbook"
  content  = local.workbook_web_json
}
