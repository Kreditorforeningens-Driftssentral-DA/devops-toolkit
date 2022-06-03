resource "docker_network" "FRONTEND" {
  name = "tf-traefik-fe"
}

module "traefik" {
  source = "./modules/container-traefik"
  
  networks = [{
    name = docker_network.FRONTEND.name,
    aliases = ["traefik","rproxy"]
  }]
}
