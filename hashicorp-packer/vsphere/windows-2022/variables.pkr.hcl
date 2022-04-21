packer {
  required_version = ">= 1.8.0"
}

/////////////////////////////////////////////////
// VARIABLES
/////////////////////////////////////////////////

variable "vcenter_credentials" {
  type = object({
    server   = string
    insecure = bool
    username = string
    password = string
  })
}

variable "vcenter_config" {
  type = object({
    datacenter = string
    datastore  = string
    network    = string
    cluster    = string
    folder     = string
  })
}

variable "static_network" {
  type = object({
    address     = string
    netmask     = string
    gateway     = string
    nameservers = list(string)
  })
}

variable "vm_name" {
  type    = string
  default = "packer-w2k22"
}

variable "vm_notes" {
  type    = string
  default = "Use SSH for provisioning, not WinRM"
}


variable "iso_installer_path" {
  type    = string
  default = ""
}

variable "iso_tools_path" {
  type    = string
  default = "[] /usr/lib/vmware/isoimages/windows.iso"
}

variable "admin_credentials" {
  type = object({
    username = string
    password = string
  })
  default = {
    username = "Packer"
    password = "P@ck3r"
  }
}

variable "disable_shutdown" {
  type    = bool
  default = true
}

variable "convert_to_template" {
  type    = bool
  default = true
}


/////////////////////////////////////////////////
// INPUTS
/////////////////////////////////////////////////

locals {
  build_by      = format("HashiCorp Packer %s", packer.version)
  build_date    = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version = formatdate("YY.MM", timestamp())

  vcenter_server   = var.vcenter_credentials.server
  vcenter_insecure = var.vcenter_credentials.insecure
  vcenter_username = var.vcenter_credentials.username
  vcenter_password = var.vcenter_credentials.password

  vcenter_datacenter = var.vcenter_config.datacenter
  vcenter_datastore  = var.vcenter_config.datastore
  vcenter_network    = var.vcenter_config.network
  vcenter_cluster    = var.vcenter_config.cluster
  vcenter_folder     = var.vcenter_config.folder

  iso_paths = compact([
    var.iso_installer_path,
    var.iso_tools_path,
  ])

  vm_name  = var.vm_name
  vm_notes = var.vm_notes

  vm_address     = var.static_network.address
  vm_netmask     = var.static_network.netmask
  vm_gateway     = var.static_network.gateway
  vm_nameservers = var.static_network.nameservers

  admin_username = var.admin_credentials.username
  admin_password = var.admin_credentials.password

  disable_shutdown = var.disable_shutdown
  convert_to_template = var.convert_to_template
}
