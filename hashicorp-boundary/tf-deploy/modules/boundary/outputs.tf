output "status" {
  value = true
  depends_on = [docker_container.CONTROLLER]
}