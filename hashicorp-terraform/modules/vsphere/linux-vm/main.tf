
/////////////////////////////////////////////////
// UNMANAGED DATASOURCES
/////////////////////////////////////////////////

data vsphere_datacenter "MAIN" {
  name = local.vsphere.datacenter
}

data vsphere_network "MAIN" {
  name = local.vsphere.network
  datacenter_id = data.vsphere_datacenter.MAIN.id
}

data vsphere_compute_cluster "MAIN" {
  name = local.vsphere.cluster
  datacenter_id = data.vsphere_datacenter.MAIN.id
}

data vsphere_virtual_machine "TEMPLATE" {
  name = local.vsphere.template
  datacenter_id = data.vsphere_datacenter.MAIN.id
}

data vsphere_datastore "MAIN" {
  name = local.vsphere.datastore
  datacenter_id = data.vsphere_datacenter.MAIN.id
}

/////////////////////////////////////////////////
// CLOUD-INIT (ovf datasource userdata)
/////////////////////////////////////////////////

data cloudinit_config "OVF" {
  gzip = false
  base64_encode = true

  part {
    filename = "kickstart.yml"
    content_type = "text/cloud-config"
    content = local.cloud_config_ovf
  }
}

/////////////////////////////////////////////////
// CLOUD-INIT (vmware datasource userdata)
/////////////////////////////////////////////////

data cloudinit_config "VMWARE" {
  gzip = true
  base64_encode = true
  
  dynamic "part" {
    for_each = { for part in local.cloud_config_vmware: part.filename => part }
    content {
      filename     = part.key
      content_type = "text/cloud-config"
      content      = part.value.content
    }
  }

  dynamic "part" {
    for_each = { for part in local.cloud_config_vmware_scripts: part.filename => part }
    content {
      filename     = part.key
      content_type = "text/x-shellscript"
      content      = part.value.content
    }
  }
}

/////////////////////////////////////////////////
// RESOURCES
/////////////////////////////////////////////////

resource "vsphere_virtual_machine" "LINUX" {
  
  // Ensure resource gets recreated if cloud-init parameters change
  replace_trigger = sha256(format("%s",
    join("-",flatten([
      data.cloudinit_config.OVF.rendered,
      data.cloudinit_config.VMWARE.rendered,
      local.network.address,
      local.network.netmask,
      local.network.gateway,
      local.dns_servers,
    ]))
  ))

  name   = local.vm_name
  folder = local.vsphere.folder
  annotation = format("%s",local.options.annotation)
  boot_delay = 2500
  wait_for_guest_net_timeout = 0

  memory   = local.resources.memory_mb
  num_cpus = local.resources.cpus

  resource_pool_id = data.vsphere_compute_cluster.MAIN.resource_pool_id
  datastore_id     = data.vsphere_datastore.MAIN.id
  firmware         = data.vsphere_virtual_machine.TEMPLATE.firmware
  scsi_type        = data.vsphere_virtual_machine.TEMPLATE.scsi_type
  guest_id         = data.vsphere_virtual_machine.TEMPLATE.guest_id

  disk {
    label = "disk0"
    size = local.resources.disk_gb
    eagerly_scrub = data.vsphere_virtual_machine.TEMPLATE.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.TEMPLATE.disks.0.thin_provisioned
  }

  network_interface {
    network_id = data.vsphere_network.MAIN.id
    adapter_type = data.vsphere_virtual_machine.TEMPLATE.network_interface_types.0
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.TEMPLATE.id
  }

  # cloud-init (OVF-Datasource)
  vapp {
    properties = {
      hostname = "ovf-kickstart"
      instance-id = "id-ovf"
      user-data = data.cloudinit_config.OVF.rendered
    }
  }

  # cloud-init (VMware-Guestinfo-Datasource)
  extra_config = {
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata.encoding" = "gzip+base64"
    
    "guestinfo.metadata" = base64gzip(templatefile("${path.module}/files/metadata.yml.j2",{
      hostname    = local.vm_name
      address     = format("%s/%s",local.network.address,local.network.netmask)
      gateway     = local.network.gateway
      dns_servers = local.dns_servers
    }))

    "guestinfo.userdata" = data.cloudinit_config.VMWARE.rendered
  }
}
