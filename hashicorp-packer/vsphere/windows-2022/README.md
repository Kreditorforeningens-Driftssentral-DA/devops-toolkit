# PACKER PROVISIONING OF WINDOWS SERVER 2022

## Description

This is an example of building a Windows base image using HashiCorp Packer from an iso-image
Packer mounts "Autounattend.xml" as a floppy-drive, and the automatic installation kicks off on first boot.

### Create base image (Autounattend.xml)
  * Install Windows Server
  * Configure local administrator account (provisioning)
  * Configure networking (static)
  * Install VMware Tools
  * Install OpenSSH-server (for further provisioning/packer communication)
  * Write useful info on the VMware VM note (for provisioning)

The resulting artifact from this build is a VMware template.
This BASE image is meant to be further provisioned.

### Provision/specialize image
  * Install any required/specialized applications & save as different template

### Deploy image (terraform)
TODO

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

vm_name = "w2k22"
iso_installer_path = "[isofiles] microsoft/windows-server-2022-x64.iso"

convert_to_template = false
```

## Known issues
TODO