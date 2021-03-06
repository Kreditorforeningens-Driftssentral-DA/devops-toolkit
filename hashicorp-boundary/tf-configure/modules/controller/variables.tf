/////////////////////////////////////////////////
// Module configuration
/////////////////////////////////////////////////

locals {
  users = defaults(var.users, {
    password = ""
    group    = ""
  })
}

/////////////////////////////////////////////////
// Module variables
/////////////////////////////////////////////////

variable "users" {
  type = list(object({
    username = string
    password = optional(string)
    group    = optional(string)
  }))
  default = []
}
