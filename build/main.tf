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
  workbook_data_json = var.deploy_to_azure ? templatefile("${path.module}/templates/workbook.tpl.json", {
    // load workbook already deployed on Azure subscription or community GitHub repo
    "summary_workbook_resource_id"           = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.summary[0].id
    "advisor_workbook_resource_id"           = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.advisor[0].id
    "export_workbook_resource_id"            = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.export[0].id
    "azuresiterecovery_workbook_resource_id" = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.azuresiterecovery[0].id
    "compute_workbook_resource_id"           = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.compute[0].id
    "containers_workbook_resource_id"        = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.containers[0].id
    "databases_workbook_resource_id"         = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.databases[0].id
    "integration_workbook_resource_id"       = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.integration[0].id
    "networking_workbook_resource_id"        = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.networking[0].id
    "storage_workbook_resource_id"           = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.storage[0].id
    "web_workbook_resource_id"               = var.load_book_from_community_gitrepo ? "TBD" : azurerm_application_insights_workbook.web[0].id
  }) : null

  armtemplate_json = templatefile("${path.module}/azuredeploy.tpl.json", {
    "workbook_json" = jsonencode(local.workbook_data_json)
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
  count = var.deploy_to_azure ? 1 : 0

  name                = random_uuid.workbook_name.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = var.workbook_name
  data_json           = local.workbook_data_json
}

// Generate workbook JSON
resource "local_file" "workbook" {
  filename = "${path.module}/ReliabilityWorkbook.json"
  content  = local.workbook_data_json
}

// Generate armtemplate JSON
resource "local_file" "armtemplate" {
  filename = "${path.module}/azuredeploy.json"
  content  = local.armtemplate_json
}
