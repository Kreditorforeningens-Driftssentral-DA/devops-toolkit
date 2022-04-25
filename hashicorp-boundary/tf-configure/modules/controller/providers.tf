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
