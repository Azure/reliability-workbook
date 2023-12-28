locals {
  // Define region
  sql_server_region = [
    "japaneast", // zone redundant
    "japanwest", // non-zone redundant
  ]
  // Define SQL Database SKU
  sql_database_sku = [
    "Basic",
    "S0",
    "P2",
    "GP_Gen5_2",
    "BC_Gen5_2",
  ]
  // Define SQL Database Backup zone redundant
  sql_database_backup_zone_redundant = [
    "Geo",
    "Zone",
    "Local"
  ]
}

// Create SQL Server
resource "azurerm_mssql_server" "example" {
  for_each = {
    for region in local.sql_server_region : region => local.sql_database_sku
  }
  name                         = "sqlserver-${each.key}-${random_string.uniqstr.result}"
  resource_group_name          = var.rg.name
  location                     = each.key
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"
}

resource "azurerm_mssql_database" "example" {
  for_each = {
    for pair in setproduct(local.sql_server_region, local.sql_database_sku) :
    "${pair[0]}-${pair[1]}" => {
      region = pair[0]
      sku    = pair[1]
    }
  }
  name           = "sqldb-${each.value.region}-${lower(replace(each.value.sku, "_", ""))}"
  server_id      = azurerm_mssql_server.example["${each.value.region}"].id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  read_scale     = false
  sku_name       = each.value.sku
  zone_redundant = false
}

// Create SQL Database with zone redundant and zone redundant backup
resource "azurerm_mssql_database" "zonal" {
  for_each             = toset(local.sql_database_backup_zone_redundant)
  name                 = "sqldb-japaneast-${lower(replace("GP_Gen5_2", "_", ""))}-${lower(each.value)}"
  server_id            = azurerm_mssql_server.example["japaneast"].id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  read_scale           = false
  sku_name             = "GP_Gen5_2"
  zone_redundant       = true
  storage_account_type = each.value
}
