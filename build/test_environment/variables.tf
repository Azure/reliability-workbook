variable "rg" {
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = "rg-test-for-workbook"
    location = "eastus"
  }
}
