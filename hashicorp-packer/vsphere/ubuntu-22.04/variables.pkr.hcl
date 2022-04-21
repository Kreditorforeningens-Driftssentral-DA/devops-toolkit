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
  default = {
    address     = "172.16.4.10"
    netmask     = "22"
    gateway     = "172.16.4.1"
    nameservers = ["1.1.1.1","8.8.8.8"]
  }
}

variable "vm_name" {
  type    = string
  default = "packer-jammy"
}

variable "vm_notes" {
  type    = string
  default = "N/A"
}

variable "iso_paths" {
  type    = list(string)
  default = []
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/jammy/ubuntu-22.04-beta-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "file:https://releases.ubuntu.com/jammy/SHA256SUMS"
}

variable "admin_credentials" {
  type = object({
    username = string
    password = string
    password_encrypted = string
    ssh_keys = list(string)
  })
  default = {
    username = "Packer"
    password = "P@ck3r"
    # echo "<PASSWORD>" | mkpasswd -m sha-512 --rounds=4096 -s
    password_encrypted = "$6$rounds=4096$5rC8cklrMaYQYddm$UvSO4UGN26emu6vHZgGiISzzZqmRfNkA5rVgjziYjUwrRT4P6gSXAUUILWvvMC/nJRD9R9EbJrObisCKgt5ZR/"
    ssh_keys = []
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

  iso_url      = var.iso_url
  iso_paths    = var.iso_paths
  iso_checksum = var.iso_checksum

  vm_name  = var.vm_name
  vm_notes = var.vm_notes

  vm_address     = format("%s/%s",var.static_network.address,var.static_network.netmask) 
  vm_gateway     = var.static_network.gateway
  vm_nameservers = var.static_network.nameservers

  ssh_username = var.admin_credentials.username
  ssh_password = var.admin_credentials.password
  ssh_password_encrypted = var.admin_credentials.password_encrypted
  ssh_keys = var.admin_credentials.ssh_keys
  
  disable_shutdown = var.disable_shutdown
  convert_to_template = var.convert_to_template
}
