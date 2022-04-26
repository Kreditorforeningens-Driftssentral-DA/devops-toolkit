/////////////////////////////////////////////////
// MODULE VARIABLES
/////////////////////////////////////////////////

variable "config" {
  type = object({
    boundary_version  = optional(string)
    postgres_version  = optional(string)
    adminer_version   = optional(string)
    whoami_version    = optional(string)
    aead_key_root     = optional(string)
    aead_key_worker   = optional(string)
    aead_key_recovery = optional(string)
  })
  default = {}
}

/////////////////////////////////////////////////
// RESOURCE PARAMETERS
/////////////////////////////////////////////////

locals {
  config = defaults(var.config,{
    boundary_version  = "latest"
    postgres_version  = "latest"
    adminer_version   = "latest"
    whoami_version    = "latest"
    aead_key_root     = "sP1fnF5Xz85RrXyELHFeZg9Ad2qt4Z4bgNHVGtD6ung="
    aead_key_worker   = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
    aead_key_recovery = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
  })
}

locals {
  images = [{
    name    = "hashicorp/boundary"
    version = local.config.boundary_version
  },{
    name    = "postgres"
    version = local.config.postgres_version
  },{
    name    = "adminer"
    version = local.config.adminer_version
  },{
    name    = "traefik/whoami"
    version = local.config.whoami_version
  }]

  keep_images_on_delete = true
}
