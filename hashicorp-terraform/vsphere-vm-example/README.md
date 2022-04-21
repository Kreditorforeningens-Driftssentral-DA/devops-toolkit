# TERRAFORM VSPHERE VM EXAMPLE

## Example use

```bash
# Initialize
terraform init

# Validate files
terraform validate 

# Source your credentials
source secret-vsphere-credentials.env

# Plan resource configuration
terraform plan -var-file "example.tfvars"

# Apply resources configuration
terraform apply -var-file "example.tfvars"

# Destroy resources
terraform destroy -var-file "example.tfvars"
```

```hcl
// File: example.tfvars
vcenter = {
  server   = "vcenter.contoso.com"
  insecure = true
}

module_example_linux_vm = {
  name       = "tf-demo0"
  folder     = ""
  datacenter = "DC1"
  cluster    = "CL1"
  network    = "VNET1"
  datastore  = "DS1"
  template   = "ubuntu-jammy-cloudimg"
  address    = "172.16.4.100"
  netmask    = "22"
  gateway    = "172.16.4.1"
}

```

## Known issues
TODO