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
  vsphere_server = local.vcenter_credentials.server
  allow_unverified_ssl = local.vcenter_credentials.insecure
  # Source credentials using ENV
}
