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
  workbook_data_json = templatefile("${path.module}/templates/workbook.tpl.json", {
    // load workbook already deployed on Azure subscription or community GitHub repo
    "summary_workbook_resource_id"           = var.load_community_git_repo ? "TBD" : azurerm_application_insights_workbook.summary[0].id
    "advisor_workbook_resource_id"           = var.load_community_git_repo ? "TBD" : azurerm_application_insights_workbook.advisor[0].id
    "export_workbook_resource_id"            = var.load_community_git_repo ? "TBD" : azurerm_application_insights_workbook.export[0].id
    "azuresiterecovery_workbook_resource_id" = var.load_community_git_repo ? "TBD" : azurerm_application_insights_workbook.azuresiterecovery[0].id

    "kql_compute_vm_resources_details"        = jsonencode(local.kql_compute_vm_resources_details)
    "kql_compute_classicvm_resources_details" = jsonencode(local.kql_compute_classicvm_resources_details)
    "kql_compute_vmss_resources_details"      = jsonencode(local.kql_compute_vmss_resources_details)

    "kql_container_aks_resources_details" = jsonencode(local.kql_container_aks_resources_details)

    "kql_database_sqldb_resources_details"         = jsonencode(local.kql_database_sqldb_resources_details)
    "kql_database_synapse_resources_details"       = jsonencode(local.kql_database_synapse_resources_details)
    "kql_database_cosmosdb_resources_details"      = jsonencode(local.kql_database_cosmosdb_resources_details)
    "kql_database_mysqlsingle_resources_details"   = jsonencode(local.kql_database_mysqlsingle_resources_details)
    "kql_database_mysqlflexible_resources_details" = jsonencode(local.kql_database_mysqlflexible_resources_details)
    "kql_database_redis_resources_details"         = jsonencode(local.kql_database_redis_resources_details)

    "kql_integration_apim_resources_details" = jsonencode(local.kql_integration_apim_resources_details)

    "kql_networking_azfw_resources_details"   = jsonencode(local.kql_networking_azfw_resources_details)
    "kql_networking_afd_resources_details"    = jsonencode(local.kql_networking_afd_resources_details)
    "kql_networking_appgw_resources_details"  = jsonencode(local.kql_networking_appgw_resources_details)
    "kql_networking_lb_resources_details"     = jsonencode(local.kql_networking_lb_resources_details)
    "kql_networking_pip_resources_details"    = jsonencode(local.kql_networking_pip_resources_details)
    "kql_networking_vnetgw_resources_details" = jsonencode(local.kql_networking_vnetgw_resources_details)

    "kql_storage_account_resources_details" = jsonencode(local.kql_storage_account_resources_details)

    "kql_webapp_appsvc_resources_details"             = jsonencode(local.kql_webapp_appsvc_resources_details)
    "kql_webapp_appsvcplan_resources_details"         = jsonencode(local.kql_webapp_appsvcplan_resources_details)
    "kql_webapp_appservice_funcapp_resources_details" = jsonencode(local.kql_webapp_appservice_funcapp_resources_details)
  })

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

  //-------------------------------------------
  // Compute tab
  //-------------------------------------------
  kql_compute_vm_resources_details = templatefile(
    "${path.module}/template_kql/compute/compute_vm_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_compute_classicvm_resources_details = templatefile(
    "${path.module}/template_kql/compute/compute_classicvm_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_compute_vmss_resources_details = templatefile(
    "${path.module}/template_kql/compute/compute_vmss_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )

  //-------------------------------------------
  // Container tab
  //-------------------------------------------
  kql_container_aks_resources_details = templatefile(
    "${path.module}/template_kql/container/container_aks_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )

  //-------------------------------------------
  // Database tab
  //-------------------------------------------
  kql_database_sqldb_resources_details = templatefile(
    "${path.module}/template_kql/database/database_sqldb_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_database_synapse_resources_details = templatefile(
    "${path.module}/template_kql/database/database_synapse_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_database_cosmosdb_resources_details = templatefile(
    "${path.module}/template_kql/database/database_cosmosdb_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_database_mysqlsingle_resources_details = templatefile(
    "${path.module}/template_kql/database/database_mysqlsingle_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_database_mysqlflexible_resources_details = templatefile(
    "${path.module}/template_kql/database/database_mysqlflexible_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_database_redis_resources_details = templatefile(
    "${path.module}/template_kql/database/database_redis_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )

  //-------------------------------------------
  // Integration tab
  //-------------------------------------------
  kql_integration_apim_resources_details = templatefile(
    "${path.module}/template_kql/integration/integration_apim_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )

  //-------------------------------------------
  // Networking tab
  //-------------------------------------------
  kql_networking_azfw_resources_details = templatefile(
    "${path.module}/template_kql/networking/networking_azfw_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_networking_afd_resources_details = templatefile(
    "${path.module}/template_kql/networking/networking_afd_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_networking_appgw_resources_details = templatefile(
    "${path.module}/template_kql/networking/networking_appgw_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_networking_lb_resources_details = templatefile(
    "${path.module}/template_kql/networking/networking_lb_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_networking_pip_resources_details = templatefile(
    "${path.module}/template_kql/networking/networking_pip_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )
  kql_networking_vnetgw_resources_details = templatefile(
    "${path.module}/template_kql/networking/networking_vnetgw_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )

  //-------------------------------------------
  // Storage tab
  //-------------------------------------------
  kql_storage_account_resources_details = templatefile(
    "${path.module}/template_kql/storage/storage_account_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )

  //-------------------------------------------
  // Web App tab
  //-------------------------------------------
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
