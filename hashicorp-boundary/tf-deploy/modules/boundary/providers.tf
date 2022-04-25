terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
  
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = ">= 2.16.0"
    }

    time = {
      source = "hashicorp/time"
      version = ">= 0.7.2"
    }
  }
}
