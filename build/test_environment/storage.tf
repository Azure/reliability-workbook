
locals {
  account_replication_type = [
    "LRS",
    "ZRS",
    "GRS",
    "RAGRS",
    "GZRS",
    "RAGZRS",
  ]
  account_replication_type_for_3plus0 = [
    "LRS",
    "ZRS",
  ]
  account_replication_type_for_v1 = [
    "LRS",
    "GRS",
    "RAGRS",
  ]
  threeplus0_region = [
    "qatarcentral",
    "polandcentral", // name will be 24 characters
    "israelcentral",
    "italynorth"
  ]
}


// Create storage account with all replication types
resource "azurerm_storage_account" "japaneast" {
  for_each = {
    for r in local.account_replication_type : r => r
  }
  name                     = "japaneast${lower(each.value)}${random_string.uniqstr.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "japaneast"
  account_tier             = "Standard"
  account_replication_type = each.value
}
// Create storage account with all 3+0 region with LRS and ZRS
resource "azurerm_storage_account" "threeplus0" {
  for_each = {
    for pair in setproduct(local.threeplus0_region, local.account_replication_type_for_3plus0) :
    "${pair[0]}-${pair[1]}" => {
      region = pair[0]
      type   = pair[1]
    }
  }

  name                     = "${each.value.region}${random_string.uniqstr.result}${lower(each.value.type)}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = each.value.region
  account_tier             = "Standard"
  account_replication_type = each.value.type
}
// Create storage account with kind v1
resource "azurerm_storage_account" "kind_v1" {
  for_each = {
    for r in local.account_replication_type_for_v1 : r => r
  }
  name                     = "japaneast${lower(each.value)}${random_string.uniqstr.result}v1"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "japaneast"
  account_tier             = "Standard"
  account_replication_type = each.value
  account_kind             = "Storage"
}

// Create storage account for non-zone region
resource "azurerm_storage_account" "non_zone" {
  for_each = {
    for r in local.account_replication_type_for_v1 : r => r
  }
  name                     = "japanwest${lower(each.value)}${random_string.uniqstr.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = "japanwest"
  account_tier             = "Standard"
  account_replication_type = each.value
}
