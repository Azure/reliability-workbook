//-------------------------------------------
// Services Alert tab
//-------------------------------------------
locals {
  service_alert_overall_summary            = file("${path.module}/template_kql/servicealerts/service_alert_overall_summary.kql")
  service_alert_overall_percentage_summary = file("${path.module}/template_kql/servicealerts/service_alert_overall_percentage_summary.kql")
  service_alert_summary_by_subscription    = file("${path.module}/template_kql/servicealerts/service_alert_summary_by_subscription.kql")
  service_alert_details                    = file("${path.module}/template_kql/servicealerts/service_alert_details.kql")


  workbook_servicealert_json = templatefile("${path.module}/templates/servicealert.tpl.json", {
    "service_alert_overall_summary"            = jsonencode(local.service_alert_overall_summary)
    "service_alert_overall_percentage_summary" = jsonencode(local.service_alert_overall_percentage_summary)
    "service_alert_summary_by_subscription"    = jsonencode(local.service_alert_summary_by_subscription)
    "service_alert_details"                    = jsonencode(local.service_alert_details)
  })
}
resource "random_uuid" "workbook_name_servicealert" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-servicealert"
  }
}

resource "azurerm_application_insights_workbook" "servicealert" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_servicealert.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-servicealert"
  data_json           = local.workbook_servicealert_json
}

resource "local_file" "servicealert" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookServiceAlert.workbook"
  content  = local.workbook_servicealert_json
}
