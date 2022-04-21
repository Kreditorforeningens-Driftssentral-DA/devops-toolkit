locals {
  modules_dir = "./../modules/vsphere"
}

module "EXAMPLE_LINUX_VM" {
  source = "./../modules/vsphere/linux-vm"
  
  // Module variables from .tfvars-file
  name = var.module_example_linux_vm.name
  vcenter_credentials = {
    server   = var.vcenter.server
    insecure = var.vcenter.insecure
  }

  vsphere = {
    folder     = var.module_example_linux_vm.folder
    datacenter = var.module_example_linux_vm.datacenter
    cluster    = var.module_example_linux_vm.cluster
    network    = var.module_example_linux_vm.network
    datastore  = var.module_example_linux_vm.datastore
    template   = var.module_example_linux_vm.template
  }

  network_static = {
    address = var.module_example_linux_vm.address
    netmask = var.module_example_linux_vm.netmask
    gateway = var.module_example_linux_vm.gateway
  }
}