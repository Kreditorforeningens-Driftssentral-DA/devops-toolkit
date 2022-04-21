variable "vcenter" {
  type = object({
    server   = string
    insecure = bool
  })
}

variable "module_example_linux_vm" {
  type = object({
    name       = string
    folder     = string
    datacenter = string
    cluster    = string
    network    = string
    datastore  = string
    template   = string
    address    = string
    netmask    = string
    gateway    = string
  })
}
