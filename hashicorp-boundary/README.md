# HASHICORP BOUNDARY

## Deployment

Deployment is done using Terraform w/docker provider

Deploys the following containers:
  * boundary-controller
  * boundary-database (postgres)
  * boundary-database-init
  * boundary-worker

Persist database to docker-volume

## Configuration

Configuration is done using Terraform w/Boundary provider
