//-------------------------------------------
// Compute tab
//-------------------------------------------
locals {
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

  workbook_compute_json = templatefile("${path.module}/templates/compute.tpl.json", {
    "kql_compute_vm_resources_details"        = jsonencode(local.kql_compute_vm_resources_details)
    "kql_compute_classicvm_resources_details" = jsonencode(local.kql_compute_classicvm_resources_details)
    "kql_compute_vmss_resources_details"      = jsonencode(local.kql_compute_vmss_resources_details)
  })
}
resource "random_uuid" "workbook_name_compute" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-compute"
  }
}

resource "azurerm_application_insights_workbook" "compute" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_compute.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-compute"
  data_json           = local.workbook_compute_json
}

resource "local_file" "compute" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookCompute.workbook"
  content  = local.workbook_compute_json
}
