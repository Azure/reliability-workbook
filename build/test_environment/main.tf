terraform {
  required_version = "~> 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = var.rg.name
  location = var.rg.location
}

resource "random_string" "uniqstr" {
  length  = 8
  special = false
  upper   = false
  numeric = false
  lower   = true
  keepers = {
    resource_group_name = var.rg.name
  }
}
