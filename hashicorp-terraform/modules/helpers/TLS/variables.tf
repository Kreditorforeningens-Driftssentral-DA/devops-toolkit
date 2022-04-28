variable "config" {
  type = object({
    ca_cert_validity_hours     = optional(number)
    cert_validity_period_hours = optional(number)
  })
  default = {}
}

variable "domains" {
  type = set(string)
  default = ["example.com"]
}

/////////////////////////////////////////////////
// Optional variables default values
/////////////////////////////////////////////////

locals {
  config = defaults(var.config,{
    ca_cert_validity_hours = 24
    cert_validity_period_hours = 8
  })
}

/////////////////////////////////////////////////
// Module variables
/////////////////////////////////////////////////

locals {
  domains = var.domains
}
