//-------------------------------------------
// Summary tab
//-------------------------------------------
locals {
  // Workbook Reliability Score
  kql_summary_workbook_reliability_score = templatefile(
    "${path.module}/template_kql/summary/summary_workbook_reliability_score.kql",
    {
      "calculate_score" = local.kql_calculate_score
      "extend_resource" = local.kql_extend_resource
      "summarize_score" = local.kql_summarize_score
    }
  )

  //Reliability Score by Resource, Environment
  kql_summary_reliability_score_by_resource_environment = templatefile(
    "${path.module}/template_kql/summary/summary_reliability_score_by_resource_environment.kql",
    {
      "calculate_score" = local.kql_calculate_score
      "extend_resource" = local.kql_extend_resource
      "summarize_score" = local.kql_summarize_score
    }
  )

  //Advisor by Recommendation
  kql_summary_advisor_by_recommendation = templatefile(
    "${path.module}/template_kql/summary/summary_advisor_by_recommendation.kql",
    {
      "advisor_recommendation" = local.kql_advisor_resource
    }
  )

  //Advisor by ResourceType
  kql_summary_advisor_by_resourcetype = templatefile(
    "${path.module}/template_kql/summary/summary_advisor_by_resourcetype.kql",
    {
      "advisor_recommendation" = local.kql_advisor_resource
    }
  )

  workbook_summary_json = templatefile("${path.module}/templates/summary.tpl.json", {
    "kql_summary_workbook_reliability_score"                = jsonencode(local.kql_summary_workbook_reliability_score)
    "kql_summary_reliability_score_by_resource_environment" = jsonencode(local.kql_summary_reliability_score_by_resource_environment)

    "kql_summary_advisor_by_recommendation" = jsonencode(local.kql_summary_advisor_by_recommendation)
    "kql_summary_advisor_by_resourcetype"   = jsonencode(local.kql_summary_advisor_by_resourcetype)
  })
}

resource "random_uuid" "workbook_name_summary" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-summary"
  }
}

resource "azurerm_application_insights_workbook" "summary" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_summary.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-summary"
  data_json           = local.workbook_summary_json
}

resource "local_file" "summary" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookSummary.workbook"
  content  = local.workbook_summary_json
}
