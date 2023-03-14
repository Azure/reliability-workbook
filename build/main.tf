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

    // Show information on Overview tab
    "overview_information" = <<-EOT
          ,{
            "type": 1,
            "content": {
              "json": "<svg viewBox=\"0 0 19 19\" width=\"20\" class=\"fxt-escapeShadow\" role=\"presentation\" focusable=\"false\" xmlns:svg=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" aria-hidden=\"true\"><g><path fill=\"#1b93eb\" d=\"M16.82 8.886c0 4.81-5.752 8.574-7.006 9.411a.477.477 0 01-.523 0C8.036 17.565 2.18 13.7 2.18 8.886V3.135a.451.451 0 01.42-.419C7.2 2.612 6.154.625 9.5.625s2.3 1.987 6.8 2.091a.479.479 0 01.523.419z\"></path><path fill=\"url(#0024423711759027356)\" d=\"M16.192 8.99c0 4.392-5.333 7.947-6.483 8.575a.319.319 0 01-.418 0c-1.15-.732-6.483-4.183-6.483-8.575V3.762a.575.575 0 01.313-.523C7.2 3.135 6.258 1.357 9.4 1.357s2.2 1.882 6.274 1.882a.45.45 0 01.419.418z\"></path><path d=\"M9.219 5.378a.313.313 0 01.562 0l.875 1.772a.314.314 0 00.236.172l1.957.284a.314.314 0 01.174.535l-1.416 1.38a.312.312 0 00-.09.278l.334 1.949a.313.313 0 01-.455.33l-1.75-.92a.314.314 0 00-.292 0l-1.75.92a.313.313 0 01-.455-.33L7.483 9.8a.312.312 0 00-.09-.278L5.977 8.141a.314.314 0 01.174-.535l1.957-.284a.314.314 0 00.236-.172z\" class=\"msportalfx-svg-c01\"></path></g></svg>&nbsp;<span style=\"font-family: Open Sans; font-weight: 620; font-size: 14px;font-style: bold;margin:-10px 0px 0px 0px;position: relative;top:-3px;left:-4px;\"> Please take the time to answer a quick survey. To submit your feedback,\r\n</span>[<span style=\"font-family: Open Sans; font-weight: 620; font-size: 14px;font-style: bold;margin:-10px 0px 0px 0px;position: relative;top:-3px;left:-4px;\"> click here. </span>](https://aka.ms/advisor_rel_wb)"
            },
            "name": "survey"
          }
    EOT
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
