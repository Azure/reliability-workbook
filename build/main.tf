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
    "servicealert_workbook_resource_id"      = azurerm_application_insights_workbook.servicealert[0].id

    // Show information on Overview tab
    "overview_information" = <<-EOT
          ,{
            "type": 1,
            "content": {
              "json": "* This workbook source is maintained publicly as OpenSource in [GitHub Repository](https://github.com/Azure/reliability-workbook). There is no Service Level guarantees or warranties associated with the usage of this workbook. Refer [license](https://github.com/Azure/reliability-workbook/blob/main/LICENSE) for more details.\r\n\r\n> If there are any bugs or suggestions for improvements, feel free to raise an issue in the above GitHub repository. In case you want to reach out to maintainers, please email to [FTA Reliability vTeam](mailto:fta-reliability-team@microsoft.com)",
              "style": "info"
            },
            "name": "text - 3"
          }
    EOT

    // Enable Summary
    "link_of_Summary" = <<-EOT
          ,{
            "id": "d6656d8e-acfc-4d7d-853d-a8c628907ba6",
            "cellValue": "selectedTab",
            "linkTarget": "parameter",
            "linkLabel": "Summary",
            "subTarget": "Summary2",
            "style": "link"
          }
    EOT

    "tab_of_Summary" = <<-EOT
    ,{
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "template",
        "loadFromTemplateId": "${azurerm_application_insights_workbook.summary[0].id}",
        "items": []
      },
      "conditionalVisibility": {
        "parameterName": "selectedTab",
        "comparison": "isEqualTo",
        "value": "Summary2"
      },
      "name": "summary group"
    }
    EOT

    // Enable Advisor
    "link_of_Advisor" = <<-EOT
         ,{
            "id": "d983c7c7-b5a0-4245-86fa-52ac1266fb13",
            "cellValue": "selectedTab",
            "linkTarget": "parameter",
            "linkLabel": "Azure Advisor",
            "subTarget": "Advisor",
            "style": "link"
          }
    EOT

    "tab_of_Advisor" = <<-EOT
    ,{
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "template",
        "loadFromTemplateId": "${azurerm_application_insights_workbook.advisor[0].id}",
        "items": []
      },
      "conditionalVisibility": {
        "parameterName": "selectedTab",
        "comparison": "isEqualTo",
        "value": "Advisor"
      },
      "name": "Advisor"
    }
    EOT

    // Enable Export
    "link_of_Export" = <<-EOT
          ,{
            "id": "0f548bfa-f959-4a25-a9ac-7c986be6d33b",
            "cellValue": "selectedTab",
            "linkTarget": "parameter",
            "linkLabel": "Export",
            "subTarget": "Export",
            "style": "link"
          }
    EOT

    "tab_of_Export" = <<-EOT
    ,{
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "template",
        "loadFromTemplateId": "${azurerm_application_insights_workbook.export[0].id}",
        "items": []
      },
      "conditionalVisibility": {
        "parameterName": "selectedTab",
        "comparison": "isEqualTo",
        "value": "Export"
      },
      "name": "ExportStep"
    }
    EOT

  }) : null

  workbook_data_json_for_public = templatefile("${path.module}/templates/workbook.tpl.json", {
    "summary_workbook_resource_id"           = "TBD"
    "azuresiterecovery_workbook_resource_id" = "community-Workbooks/Azure Advisor/Reliability/AzureSiteRecovery"
    "compute_workbook_resource_id"           = "community-Workbooks/Azure Advisor/Reliability/Compute"
    "containers_workbook_resource_id"        = "community-Workbooks/Azure Advisor/Reliability/Containers"
    "databases_workbook_resource_id"         = "community-Workbooks/Azure Advisor/Reliability/Databases"
    "integration_workbook_resource_id"       = "community-Workbooks/Azure Advisor/Reliability/Integration"
    "networking_workbook_resource_id"        = "community-Workbooks/Azure Advisor/Reliability/Networking"
    "storage_workbook_resource_id"           = "community-Workbooks/Azure Advisor/Reliability/Storage"
    "web_workbook_resource_id"               = "community-Workbooks/Azure Advisor/Reliability/Web"
    "servicealert_workbook_resource_id"      = "community-Workbooks/Azure Advisor/Reliability/ServiceAlert"

    "overview_information" = ""
    "link_of_Summary"      = ""
    "tab_of_Summary"       = ""
    "link_of_Advisor"      = ""
    "tab_of_Advisor"       = ""
    "link_of_Export"       = ""
    "tab_of_Export"        = ""
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
  filename = "${path.module}/ReliabilityWorkbook.workbook"
  content  = local.workbook_data_json_for_community
}

resource "local_file" "workbook_public" {
  filename = "${path.module}/ReliabilityWorkbookPublic.workbook"
  content  = local.workbook_data_json_for_public
}

// Generate armtemplate JSON
resource "local_file" "armtemplate" {
  filename = "${path.module}/azuredeploy.json"
  content  = local.armtemplate_json
}
