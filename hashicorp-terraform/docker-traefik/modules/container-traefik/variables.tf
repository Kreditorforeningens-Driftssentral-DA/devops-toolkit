variable "networks" {
  type = list(object({
    name  = string
    aliases = list(string)
  }))
  default = []
}

variable "keep_images" {
  type = bool
  default = true
}