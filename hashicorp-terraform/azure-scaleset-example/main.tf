variable "module_settings" {
  type = object({
    prefix   = string
    location = string
    scale    = number
  })
  default = {
    prefix   = "demo"
    location = "NorwayEast"
    scale    = 1
  }
}

resource "random_id" "ID" {
  keepers = {
    resource_location = var.module_settings.location,
  }
  byte_length = 5
}

locals {
  prefix   = format("%s-%s", var.module_settings.prefix, random_id.ID.id)
  location = var.module_settings.location
  scale    = var.module_settings.scale
}

resource "azurerm_resource_group" "MAIN" {
  name     = local.prefix
  location = local.location
}

module "VMS" {
  source = "../modules/azure/standalone-linux-scaleset"
  config = {
    resource_group_name = azurerm_resource_group.MAIN.name
    prefix = local.prefix
    scale  = local.scale
  }
}
