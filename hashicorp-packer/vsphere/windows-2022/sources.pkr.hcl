/////////////////////////////////////////////////
// SOURCES
// https://www.packer.io/plugins/builders/vsphere/vsphere-iso
/////////////////////////////////////////////////

source "vsphere-iso" "W2K22" {
  
  vcenter_server = local.vcenter_server
  insecure_connection = local.vcenter_insecure  
  
  username   = local.vcenter_username
  password   = local.vcenter_password
  datacenter = local.vcenter_datacenter
  datastore  = local.vcenter_datastore
  cluster    = local.vcenter_cluster
  folder     = local.vcenter_folder

  vm_name    = format("%s-v%s",local.vm_name,local.build_version)
  vm_version = 14
  
  notes = format("Builder: %s\nBuilt: %s\nLocalAdmin: %s (%s)\n\n%s",
    local.build_by,
    local.build_date,
    local.admin_username,local.admin_password,
    local.vm_notes,
  )
  
  boot_order   = "disk,cdrom"
  boot_wait    = "2s"
  boot_command = ["<spacebar>"]

  CPUs      = 2
  cpu_cores = 1
  RAM       = 4 * 1024
  
  CPU_hot_plug = false
  RAM_hot_plug = false

  guest_os_type        = "windows9_64Guest"
  firmware             = "bios"
  cdrom_type           = "ide"
  disk_controller_type = ["lsilogic-sas"]
  
  iso_paths = local.iso_paths

  storage {
    disk_size             = 32 * 1024
    disk_controller_index = 0
    disk_thin_provisioned = true
  }
  
  network_adapters {
    network      = local.vcenter_network
    network_card = "e1000"
  }
 
  floppy_content = {
    
    "Autounattend.xml" = templatefile("${path.root}/templates/Autounattend.FILES.xml.tpl",{
      hostname = "w2k22" # BUG: do not use same hostname and ssh-username
      username = local.admin_username
      password = local.admin_password
      files = [
        "A:\\DisableUpdates.ps1",
        "A:\\Networking.ps1",
        "A:\\OpenSSH.ps1",
        "A:\\VMwareTools.ps1", # Run this last; Packer uses VMware-tools to retrieve ip-address automatically.
      ]
    })

    "Networking.ps1" = templatefile("${path.root}/templates/PS-Networking.STATIC.ps1.tpl", {
      address     = local.vm_address
      netmask     = local.vm_netmask
      gateway     = local.vm_gateway
      nameservers = local.vm_nameservers
    })

    "DisableUpdates.ps1" = file("${path.root}/raw/PS-WindowsUpdateDisable.ps1")
    "OpenSSH.ps1"        = file("${path.root}/raw/PS-OpenSSH.ps1")
    "VMwareTools.ps1"    = file("${path.root}/raw/PS-VMwareTools.ps1")
  }

  ip_wait_timeout  = "120m"

  communicator = "ssh"
  ssh_timeout  = "120m"
  ssh_port     = 22
  ssh_handshake_attempts = "100000"

  ssh_username = local.admin_username
  ssh_password = local.admin_password
  ssh_clear_authorized_keys = true
    
  shutdown_timeout     = "120m"
  tools_upgrade_policy = true
  remove_cdrom         = true
  
  disable_shutdown = local.disable_shutdown
  convert_to_template  = local.convert_to_template
}
