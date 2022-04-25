terraform {
  
  // defaults / optional variables
  experiments = [ module_variable_optional_attrs ]
  
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = ">= 1.0.6"
    }
  }
}

provider "boundary" {
  addr = "http://127.0.0.1:9200"
  tls_insecure = true

  recovery_kms_hcl = <<-EOH
  kms "aead" {
    purpose = "recovery"
    aead_type = "aes-gcm"
    key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
    key_id = "global_recovery"
  }
  EOH
}