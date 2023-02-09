//-------------------------------------------
// Databases tab
//-------------------------------------------
locals {
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

  workbook_databases_json = templatefile("${path.module}/templates/databases.tpl.json", {
    "kql_database_sqldb_resources_details"         = jsonencode(local.kql_database_sqldb_resources_details)
    "kql_database_synapse_resources_details"       = jsonencode(local.kql_database_synapse_resources_details)
    "kql_database_cosmosdb_resources_details"      = jsonencode(local.kql_database_cosmosdb_resources_details)
    "kql_database_mysqlsingle_resources_details"   = jsonencode(local.kql_database_mysqlsingle_resources_details)
    "kql_database_mysqlflexible_resources_details" = jsonencode(local.kql_database_mysqlflexible_resources_details)
    "kql_database_redis_resources_details"         = jsonencode(local.kql_database_redis_resources_details)
  })
}
resource "random_uuid" "workbook_name_databases" {
  keepers = {
    name = "${var.rg.name}${var.workbook_name}-databases"
  }
}

resource "azurerm_application_insights_workbook" "databases" {
  count = var.deploy_community_edition_to_azure ? 1 : 0

  name                = random_uuid.workbook_name_databases.result
  resource_group_name = var.rg.name
  location            = var.rg.location
  display_name        = "${var.workbook_name}-databases"
  data_json           = local.workbook_databases_json
}

resource "local_file" "databases" {
  filename = "${path.module}/artifacts/ReliabilityWorkbookDatabases.workbook"
  content  = local.workbook_databases_json
}
