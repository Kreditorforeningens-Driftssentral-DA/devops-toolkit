# CHANGELOG

## March 25, 2022
HASHICORP-BOUNDARY:
  * Added local Boundary deployment [example](hashicorp-boundary/tf-deploy) (using local terraform module + docker provider). NOTE: No targets added.
  * Added local Boundary configuration [example](hashicorp-boundary/tf-configure) (using local terraform module + boundary provider). Only password auth enabled.

---

## March 21, 2022
HASHICORP-TERRAFORM:
  * Added example vSphere [module](hashicorp-terraform/modules/vsphere/linux-vm) & [project](hashicorp-terraform/vsphere-vm-example) for deploying a Linux server from a template.

---

## March 20, 2022
HASHICORP-PACKER:
  * Added vSphere [example](hashicorp-packer/vsphere/windows-2022) of creating Windows Server base image from ISO
  * Added vSphere [example](hashicorp-packer/vsphere/ubuntu-22.04) of creating Ubuntu Server base image from ISO
