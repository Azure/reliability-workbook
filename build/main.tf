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
  link_of_Export = var.deploy_community_edition_to_azure ? templatefile("${path.module}/templates/export_link.tpl.json", {}) : ""
  tab_of_Export = var.deploy_community_edition_to_azure ? templatefile("${path.module}/templates/export_tab.tpl.json", {
    "export_workbook_resource_id" = azurerm_application_insights_workbook.export[0].id
  }) : ""
  link_of_Advisor = var.deploy_community_edition_to_azure ? templatefile("${path.module}/templates/advisor_link.tpl.json", {}) : ""
  tab_of_Advisor = var.deploy_community_edition_to_azure ? templatefile("${path.module}/templates/advisor_tab.tpl.json", {
    "advisor_workbook_resource_id" = azurerm_application_insights_workbook.advisor[0].id
  }) : ""
  workbook_data_json_for_community = var.deploy_community_edition_to_azure ? templatefile("${path.module}/templates/workbook.tpl.json", {
    // load workbook already deployed on Azure subscription or community GitHub repo
    "summary_workbook_resource_id"           = azurerm_application_insights_workbook.summary[0].id
    "azuresiterecovery_workbook_resource_id" = azurerm_application_insights_workbook.azuresiterecovery[0].id
    "compute_workbook_resource_id"           = azurerm_application_insights_workbook.compute[0].id
    "containers_workbook_resource_id"        = azurerm_application_insights_workbook.containers[0].id
    "databases_workbook_resource_id"         = azurerm_application_insights_workbook.databases[0].id
    "integration_workbook_resource_id"       = azurerm_application_insights_workbook.integration[0].id
    "networking_workbook_resource_id"        = azurerm_application_insights_workbook.networking[0].id
    "storage_workbook_resource_id"           = azurerm_application_insights_workbook.storage[0].id
    "web_workbook_resource_id"               = azurerm_application_insights_workbook.web[0].id

    "link_of_Export"   = local.link_of_Export
    "tab_of_Export"    = local.tab_of_Export
    "linke_of_Advisor" = local.link_of_Advisor
    "tab_of_Advisor"   = local.tab_of_Advisor
  }) : null

  workbook_data_json_for_public = templatefile("${path.module}/templates/workbook.tpl.json", {
    "summary_workbook_resource_id"           = "TBD"
    "azuresiterecovery_workbook_resource_id" = "TBD"
    "compute_workbook_resource_id"           = "TBD"
    "containers_workbook_resource_id"        = "TBD"
    "databases_workbook_resource_id"         = "TBD"
    "integration_workbook_resource_id"       = "TBD"
    "networking_workbook_resource_id"        = "TBD"
    "storage_workbook_resource_id"           = "TBD"
    "web_workbook_resource_id"               = "TBD"

    "link_of_Export"   = local.link_of_Export
    "tab_of_Export"    = local.tab_of_Export
    "linke_of_Advisor" = local.link_of_Advisor
    "tab_of_Advisor"   = local.tab_of_Advisor
  })

  armtemplate_json = templatefile("${path.module}/azuredeploy.tpl.json", {
    "workbook_json" = jsonencode(local.workbook_data_json_for_community)
  })

  //-------------------------------------------
  // Common KQL queries
  //-------------------------------------------
  kql_calculate_score  = file("${path.module}/template_kql/common/calculate_score.kql")
  kql_extend_resource  = file("${path.module}/template_kql/common/extend_resource.kql")
  kql_summarize_score  = file("${path.module}/template_kql/common/summarize_score.kql")
  kql_advisor_resource = file("${path.module}/template_kql/advisor/advisor_recommendation_details.kql")

}
//-------------------------------------------
// Create template file
//-------------------------------------------
resource "random_uuid" "workbook_name" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}"
  }
}

// Deploy Workbook to Azure
resource "azurerm_application_insights_workbook" "example" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = var.workbook_name
  data_json           = local.workbook_data_json_for_community
}

// Generate workbook JSON
resource "local_file" "workbook" {
  filename = "${path.module}/ReliabilityWorkbook.json"
  content  = local.workbook_data_json_for_community
}

resource "local_file" "workbook_public" {
  filename = "${path.module}/ReliabilityWorkbookPublic.json"
  content  = local.workbook_data_json_for_public
}

// Generate armtemplate JSON
resource "local_file" "armtemplate" {
  filename = "${path.module}/azuredeploy.json"
  content  = local.armtemplate_json
}
