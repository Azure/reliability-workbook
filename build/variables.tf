variable "rg" {
  type = object({
    name     = string
    location = string
  })
  default = {
    location = "japaneast"
    name     = "rg-workbook"
  }
}

variable "workbook_name" {
  type    = string
  default = "FTA - Reliability Workbook"
}

variable "deploy_community_edition_to_azure" {
  type    = bool
  default = false
}
