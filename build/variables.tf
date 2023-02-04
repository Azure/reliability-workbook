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

variable "deploy_to_azure" {
  type    = bool
  default = false
}

variable "load_book_from_community_gitrepo" {
  type    = bool
  default = false
}

variable "is_fta_edition" {
  type    = bool
  default = false
}
