/////////////////////////////////////////////////
// BUILDS
/////////////////////////////////////////////////

build {
  sources = [
    "source.vsphere-iso.W2K22",
  ]
  
  provisioner "windows-restart" {
    pause_before = "15s"
    restart_timeout = "15m"
  }
  
  /*
  provisioner "file" {
    name = "upload"
    sources = [
      "raw/windows-update.ps1",
      "raw/customize.ps1",
      "raw/v1.bgi",
    ]
    destination = "C:\\Packer\\"
  }

  provisioner "powershell" {
    valid_exit_codes = [0,2300218]
    inline = [
      "Write-Host \"Hello from PowerShell\"",
    ]
  }*/

  /*
  post-processors {
    
    post-processor "vsphere-template" {
      host       = local.vcenter_server
      insecure   = local.vcenter_insecure  
      username   = local.vcenter_username
      password   = local.vcenter_password
      datacenter = local.vcenter_datacenter
      folder     = "/_Templates/"
    }
  }*/
}
