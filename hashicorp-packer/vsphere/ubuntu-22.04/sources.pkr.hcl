/////////////////////////////////////////////////
// SOURCES vsphere-iso
// https://www.packer.io/plugins/builders/vsphere/vsphere-iso
/////////////////////////////////////////////////

source "vsphere-iso" "UBUNTU" {
  
  vcenter_server      = local.vcenter_server
  insecure_connection = local.vcenter_insecure  
  
  username   = local.vcenter_username
  password   = local.vcenter_password
  datacenter = local.vcenter_datacenter
  datastore  = local.vcenter_datastore
  cluster    = local.vcenter_cluster
  folder     = local.vcenter_folder

  vm_name    = format("%s-v%s",local.vm_name,local.build_version)
  vm_version = "11" #14?

  notes = format("Builder: %s\nBuilt on: %s\nLocalAdmin: %s (%s)\nNote: %s",
    local.build_by,
    local.build_date,
    local.ssh_username,local.ssh_password,
    local.vm_notes
  )

  boot_order = "disk,cdrom"
  boot_wait = "5s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=nocloud-net","<enter><wait>",
    "initrd /casper/initrd","<enter><wait>",
    "boot","<enter>"
  ]

  CPUs      = 2
  cpu_cores = 1
  RAM       = 4 * 1024

  CPU_hot_plug = false
  RAM_hot_plug = false

  guest_os_type        = "ubuntu64Guest" # https://developer.vmware.com/apis/358/vsphere/doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
  firmware             = "efi"
  cdrom_type           = "ide"
  disk_controller_type = ["pvscsi"]

  iso_url      = local.iso_url
  iso_checksum = local.iso_checksum
  iso_paths    = local.iso_paths

  storage {
    disk_size = 20 * 1024
    disk_controller_index = 0
    disk_thin_provisioned = true
  }
  
  network_adapters {
    network = local.vcenter_network
    network_card = "vmxnet3"
  }
 
  http_directory = ""
  cd_label = "CIDATA"
  cd_files = []
  cd_content = {
    "meta-data" = file("templates/subiquity/meta-data")
    "user-data" = templatefile("templates/subiquity/user-data.tpl",{
      hostname    = local.vm_name
      username    = local.ssh_username
      password    = local.ssh_password_encrypted
      address     = local.vm_address
      gateway     = local.vm_gateway
      nameservers = local.vm_nameservers
      ssh_keys    = local.ssh_keys
    })
  }

  ip_wait_timeout = "30m"

  communicator = "ssh"
  ssh_port     = 22
  ssh_timeout  = "600m"
  ssh_handshake_attempts = "100000"

  ssh_username = local.ssh_username
  ssh_password = local.ssh_password
  ssh_clear_authorized_keys = true

  shutdown_timeout = "5m"
  shutdown_command = "echo '${local.ssh_password}' | sudo -S -E shutdown -P now"
  tools_upgrade_policy = true
  remove_cdrom = true  

  disable_shutdown = local.disable_shutdown
  convert_to_template = local.convert_to_template
}
