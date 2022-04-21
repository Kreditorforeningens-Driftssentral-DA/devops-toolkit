# PACKER PROVISIONING OF UBUNTU 22.04 JAMMY

## Description

This is an example of building a Linux base image using HashiCorp Packer from an iso-image.
Packer mounts "cloud-init" ("Autoinstall" wrapper) files as a "CIDATA" floppy-drive, and the
automatic installation kicks off on first boot by use of custom GRUB command.

### Create base image (Cloud-Init)
  * Install Ubuntu Server (22.04)
  * Configure local administrator account (provisioning)
  * Configure networking (static)
  * Install OpenVM Tools
  * Configure/reset cloud-init datasource (VMware)
  * Install security updates
  * Write useful info on the VMware VM note (provisioning)

The resulting artifact from this build is a VMware template.
This BASE image is meant to be further provisioned.

### Provision/specialize image (packer/ssh)
  * Install any required/specialized applications & save as different template

### Deploy image (terraform)
  * Specialized images are deployed using Terraform. Server-specific settings are configured at this stage (e.g. configuration-files, clustering)

## Example use

```bash
# Validate files
packer validate -var-file "example.pkrvars.hcl" .

# Build Image
packer build -var-file "example.pkrvars.hcl" .
```

```bash
# Example: example.pkrvars.hcl
vcenter_credentials = {
  server   = "vmware.contoso.com"
  insecure = true
  username = "superperson@contoso.com"
  password = "SurelyShirley"
}

vcenter_config = {
  datacenter = "DC1"
  datastore  = "DS1"
  network    = "NW1"
  cluster    = "CL1"
  folder     = "/"
}

admin_credentials = {
  username = "Packer"
  password = "P@ck3r"
}

static_network = {
  address = "192.168.0.100"
  netmask = "24"
  gateway = "192.168.0.1"
  nameservers = ["1.1.1.1","8.8.8.8"]
}

vm_name = "jammy"
iso_installer_path = "[isofiles] canonical/ubuntu-server-2204-x64.iso"

convert_to_template = false
```

## Known issues
TODO