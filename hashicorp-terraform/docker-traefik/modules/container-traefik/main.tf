locals {
  networks = var.networks
  keep_images = var.keep_images
}

locals {
  container_image = "traefik:latest"
  container_name  = "traefik"

  labels = {
    "traefik.enable" = "false"
  }

  container_args = [
    "--experimental.http3=true",
    "--global.checknewversion=false",
    "--pilot.dashboard=false",
    "--ping=true",
    "--api=true",
    "--api.dashboard=true",
    "--api.insecure=true",
    "--accesslog=true",
    "--log=true",
    "--entrypoints.WEB=true",
    "--entrypoints.WEB.address=:80",
    "--entrypoints.WEB.forwardedheaders.insecure=true",
    "--entrypoints.WEBSECURE=true",
    "--entrypoints.WEBSECURE.address=:443",
    "--providers.file.directory=/files",
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",
    "--providers.consulcatalog=false",
    "--providers.consulcatalog.refreshinterval=60",
    "--providers.consulcatalog.connectaware=true",
    "--providers.consulcatalog.servicename=traefik",
    "--providers.consulcatalog.prefix=traefik",
    "--providers.consulcatalog.exposedbydefault=false",
    "--providers.consulcatalog.connectbydefault=true",
    "--metrics.prometheus=true",
    "--metrics.prometheus.entryPoint=traefik",
    "--metrics.prometheus.addEntryPointsLabels=true",
    "--metrics.prometheus.addrouterslabels=false",
    "--metrics.prometheus.addServicesLabels=true",
  ]

  container_ports = [{
    internal = 8080
    external = 8080
  },{
    internal = 80
    external = 80
  },{
    internal = 443
    external = 443
  }]

  uploads = [{
    file = "/files/middleware.yml"
    content = <<-HEREDOC
    ---
    http:
      middlewares:
        LatencyCheck50ms:
          circuitBreaker:
            expression: "LatencyAtQuantileMS(50.0) > 100"
    ...
    HEREDOC
  }]

  bind_mounts = [{
    source = "/var/run/docker.sock"
    target = "/var/run/docker.sock"
  }]
}

//////////////////////////////////
// Resources
//////////////////////////////////

data "docker_registry_image" "MAIN" {
  name = local.container_image
}

resource "docker_image" "MAIN" {
  name = data.docker_registry_image.MAIN.name
  keep_locally = local.keep_images
  pull_triggers = [data.docker_registry_image.MAIN.sha256_digest]
}

resource "docker_container" "MAIN" {
  name  = local.container_name
  
  hostname = "traefik"
  image = docker_image.MAIN.latest

  command = local.container_args

  dynamic "labels" {
    for_each = local.labels

    content {
      label = labels.key
      value = labels.value
    }
  }

  dynamic "networks_advanced" {
    for_each = local.networks

    content {
      name = networks_advanced.value.name
      aliases = networks_advanced.value.aliases
    }
  }

  dynamic "ports" {
    for_each = local.container_ports

    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }

  dynamic "upload" {
    for_each = local.uploads

    content {
      file = upload.value.file
      content = upload.value.content
    }
  }

  dynamic "mounts" {
    for_each = local.bind_mounts

    content {
      type = "bind"
      source = mounts.value.source
      target = mounts.value.target
      read_only = true
    }
  }
}