terraform {
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

# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "time" {}
