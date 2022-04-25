# See https://github.com/hashicorp/boundary-reference-architecture/blob/main/deployment/docker/compose/docker-compose.yml

/////////////////////////////////////////////////
// Docker host resources
/////////////////////////////////////////////////

data "docker_registry_image" "IMAGE" {
  for_each = { for image in local.images: image.name => image }
  name = format("%s:%s",each.key,each.value.version)
}

resource "docker_image" "IMAGE" {
  for_each = { for image in local.images: image.name => image }

  name = data.docker_registry_image.IMAGE[each.key].name
  keep_locally = local.keep_images_on_delete
  
  pull_triggers = [
    data.docker_registry_image.IMAGE[each.key].sha256_digest
  ]
}

resource "docker_volume" "DATABASE" {
  name = "boundary-db"
}

resource "docker_network" "FRONTEND" {
  name = "boundary-fe"
}

resource "docker_network" "BACKEND" {
  name = "boundary-be"
}

/////////////////////////////////////////////////
// Delays (timing workaround)
/////////////////////////////////////////////////

resource "time_sleep" "WAIT_DB_READY" {
  create_duration = "5s"
  depends_on = [
    docker_container.DATABASE
  ]
}

resource "time_sleep" "WAIT_DB_INITIALIZED" {
  create_duration = "5s"
  depends_on = [
    docker_container.DATABASE,
    docker_container.DATABASE_INIT,
    time_sleep.WAIT_DB_READY,
  ]
}

/////////////////////////////////////////////////
// Boundary Database
/////////////////////////////////////////////////

# Create a container
resource "docker_container" "DATABASE" {
  image = docker_image.IMAGE["postgres"].latest
  name  = "boundary-database"

  env = [
    "POSTGRES_DB=boundary",
    "POSTGRES_USER=boundary",
    "POSTGRES_PASSWORD=boundary",
    "PGDATA=/var/lib/postgresql/data/pgdata",
  ]
  
  networks_advanced {
    name = docker_network.BACKEND.name
    aliases = ["db"]
  }

  volumes {
    container_path = "/var/lib/postgresql/data/pgdata"
    volume_name = docker_volume.DATABASE.name
  }
  
  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U boundary"]
    interval = "5s"
    timeout  = "5s"
    retries  = 5
  }
}

/////////////////////////////////////////////////
// Boundary Database Initializer
/////////////////////////////////////////////////

resource "docker_container" "DATABASE_INIT" {
  image = docker_image.IMAGE["hashicorp/boundary"].latest
  name  = "boundary-database-init"

  env = [
    "BOUNDARY_PG_URL=postgresql://boundary:boundary@db/boundary?sslmode=disable",
  ]

  command = [
    "database","init",
    "-config","/boundary/boundary.hcl",
    "-config-kms","/boundary/kms.hcl",
    "-skip-initial-login-role-creation",
    "-skip-auth-method-creation",
    "-skip-scopes-creation",
    "-skip-host-resources-creation",
    "-skip-target-creation",
  ]
  
  networks_advanced {
    name = docker_network.BACKEND.name
    aliases = ["db-init"]
  }
  
  upload {
    file = "/boundary/boundary.hcl"
    content_base64 = base64encode(templatefile("${path.module}/files/boundary.hcl.tpl",{}))
  }

  upload {
    file = "/boundary/kms.hcl"
    content_base64 = base64encode(templatefile("${path.module}/files/kms.hcl.tpl",{}))
  }

  capabilities {
    add = [
      "IPC_LOCK"
    ]
  }
  
  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U boundary"]
    interval = "5s"
    timeout  = "5s"
    retries  = 5
  }

  depends_on = [
    docker_container.DATABASE,
    time_sleep.WAIT_DB_READY,
  ]
}


/////////////////////////////////////////////////
// Boundary Controller
/////////////////////////////////////////////////

resource "docker_container" "CONTROLLER" {
  image = docker_image.IMAGE["hashicorp/boundary"].latest
  name  = "boundary-controller"

  env = [
    "BOUNDARY_PG_URL=postgresql://boundary:boundary@db/boundary?sslmode=disable",
  ]

  command = [
    "server",
    "-config","/boundary/boundary.hcl",
    "-config-kms","/boundary/kms.hcl",
  ]

  networks_advanced {
    name = docker_network.FRONTEND.name
    aliases = ["controller"]
  }
  
  networks_advanced {
    name = docker_network.BACKEND.name
    aliases = ["controller"]
  }

  ports {
    internal = 9200
    external = 9200
  }

  upload {
    file = "/boundary/boundary.hcl"
    content_base64 = base64encode(templatefile("${path.module}/files/boundary.hcl.tpl",{}))
  }

  upload {
    file = "/boundary/kms.hcl"
    content_base64 = base64encode(templatefile("${path.module}/files/kms.hcl.tpl",{}))
  }

  capabilities {
    add = [
      "IPC_LOCK"
    ]
  }

  healthcheck {
    test     = ["CMD","wget","-O-","http://localhost:9200"]
    interval = "5s"
    timeout  = "5s"
    retries  = 5
  }

  depends_on = [
    docker_container.DATABASE,
    docker_container.DATABASE_INIT,
    time_sleep.WAIT_DB_INITIALIZED,
  ]
}

/////////////////////////////////////////////////
// Boundary Worker(s)
/////////////////////////////////////////////////
// N/A