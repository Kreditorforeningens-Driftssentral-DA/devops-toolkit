/////////////////////////////////////////////////
// TERRAFORM
/////////////////////////////////////////////////

terraform {
  required_version = ">= 1.0"
   
   // Experimental features:
   // - defaults()
  experiments = [module_variable_optional_attrs]

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 1.24.3"
    }
  }
}

provider "vsphere" {
  vsphere_server       = var.vcenter.server
  allow_unverified_ssl = var.vcenter.insecure
  # Source credentials using ENV
}
