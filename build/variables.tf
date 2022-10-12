variable "rg" {
  type = object({
    name     = string
    location = string
  })
}

variable "workbook_name" {
  type = string
}

variable "deploy_to_azure" {
  type    = bool
  default = false
}
