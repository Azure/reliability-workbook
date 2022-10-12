terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

locals {
  workbook_data_json = templatefile("${path.module}/workbook.tpl.json", {
    "kql_summary_workbook_reliability_score"                                    = jsonencode(local.kql_summary_workbook_reliability_score)
    "kql_summary_reliability_score_by_resource_environment_and_criticality"     = jsonencode(local.kql_summary_reliability_score_by_resource_environment_and_criticality)
    "kql_summary_reliability_score_by_resourceType_environment_and_criticality" = jsonencode(local.kql_summary_reliability_score_by_resourceType_environment_and_criticality)
    "kql_export_summary_by_resourceType_environment_criticality"                = jsonencode(local.kql_export_summary_by_resourceType_environment_criticality)
    "kql_export_summary_by_resource_environment_criticality"                    = jsonencode(local.kql_export_summary_by_resource_environment_criticality)
    "kql_export_resources_details"                                              = jsonencode(local.kql_export_resources_details)
  })

  //-------------------------------------------
  // Common KQL queries
  //-------------------------------------------
  kql_score = file("${path.module}/template_kql/score.kql")

  //-------------------------------------------
  // Summary tab
  //-------------------------------------------
  // Workbook Reliability Score
  kql_summary_workbook_reliability_score = templatefile(
    "${path.module}/template_kql/summary_workbook_reliability_score.kql",
    {
      "score" = local.kql_score
    }
  )

  //Reliability Score by Resource, Environment and Criticality
  kql_summary_reliability_score_by_resource_environment_and_criticality = templatefile(
    "${path.module}/template_kql/summary_reliability_score_by_resource_environment_and_criticality.kql",
    {
      "score" = local.kql_score
    }
  )

  // Reliability Score by Resource Type, Environment and Criticality
  kql_summary_reliability_score_by_resourceType_environment_and_criticality = templatefile(
    "${path.module}/template_kql/summary_reliability_score_by_resourceType_environment_and_criticality.kql",
    {
      "score" = local.kql_score
    }
  )

  //-------------------------------------------
  // Export tab
  //-------------------------------------------
  // Summary by Resource Type, Environment, Criticality
  kql_export_summary_by_resourceType_environment_criticality = templatefile(
    "${path.module}/template_kql/export_summary_by_resourceType_environment_criticality.kql",
    {
      "score" = local.kql_score
    }
  )
  // Summary by Resource, Environment, Criticality
  kql_export_summary_by_resource_environment_criticality = templatefile(
    "${path.module}/template_kql/export_summary_by_resource_environment_criticality.kql",
    {
      "score" = local.kql_score
    }
  )
  // Resources Details
  kql_export_resources_details = file("${path.module}/template_kql/export_resources_details.kql")
}

resource "random_uuid" "workbook_name" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}"
  }
}

resource "azurerm_application_insights_workbook" "example" {
  count = var.deploy_to_azure ? 1 : 0

  name                = random_uuid.workbook_name.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = var.workbook_name
  data_json           = local.workbook_data_json
}

resource "local_file" "workbook" {
  filename = "${path.module}/Reliability Workbook.json"
  content  = local.workbook_data_json
}
