//-------------------------------------------
// Networking tab
//-------------------------------------------
locals {

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
  workbook_networking_json = templatefile("${path.module}/templates/networking.tpl.json", {
    "kql_networking_azfw_resources_details"   = jsonencode(local.kql_networking_azfw_resources_details)
    "kql_networking_afd_resources_details"    = jsonencode(local.kql_networking_afd_resources_details)
    "kql_networking_appgw_resources_details"  = jsonencode(local.kql_networking_appgw_resources_details)
    "kql_networking_lb_resources_details"     = jsonencode(local.kql_networking_lb_resources_details)
    "kql_networking_pip_resources_details"    = jsonencode(local.kql_networking_pip_resources_details)
    "kql_networking_vnetgw_resources_details" = jsonencode(local.kql_networking_vnetgw_resources_details)
  })
}
resource "random_uuid" "workbook_name_networking" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-networking"
  }
}

resource "azurerm_application_insights_workbook" "networking" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_networking.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-networking"
  data_json           = local.workbook_networking_json
}

resource "local_file" "networking" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookNetworking.workbook"
  content  = local.workbook_networking_json
}
