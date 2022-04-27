/////////////////////////////////////////////////
// Module variables
/////////////////////////////////////////////////

variable "config" {
  type = object({
    resource_group_name = string
    scale               = optional(number)
    prefix              = optional(string)
    vnet_name           = optional(string)
    subnet_name         = optional(string)
    vnet_address_space  = optional(string)
    subnet_prefixes     = optional(string)
  })
}

locals {
  // Set default values for optional variable parameters
  config = defaults(var.config,{
    scale               = 1
    prefix              = "demo"
    vnet_name           = "vnet"
    subnet_name         = "subnet"
    vnet_address_space  = "172.16.0.0/16"
    subnet_prefixes     = "172.16.0.0/22"
  })
}

/////////////////////////////////////////////////
// Module inputs
/////////////////////////////////////////////////

locals {
  resource_group_name = local.config.resource_group_name
  prefix              = local.config.prefix
  scale               = local.config.scale
  vnet_name           = local.config.vnet_name
  vnet_address_space  = [local.config.vnet_address_space]
  subnet_name         = local.config.subnet_name
  subnet_prefixes     = [local.config.subnet_prefixes]
}
