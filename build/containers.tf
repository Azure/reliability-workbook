//-------------------------------------------
// Containers tab
//-------------------------------------------
locals {
  kql_container_aks_resources_details = templatefile(
    "${path.module}/template_kql/container/container_aks_resources_details.kql",
    {
      "extend_resource" = local.kql_extend_resource
    }
  )

  workbook_containers_json = templatefile("${path.module}/templates/containers.tpl.json", {
    "kql_container_aks_resources_details" = jsonencode(local.kql_container_aks_resources_details)
  })
}
resource "random_uuid" "workbook_name_containers" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-containers"
  }
}

resource "azurerm_application_insights_workbook" "containers" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_containers.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-containers"
  data_json           = local.workbook_containers_json
}

resource "local_file" "containers" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookContainers.workbook"
  content  = local.workbook_containers_json
}
