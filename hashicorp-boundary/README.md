# HASHICORP BOUNDARY

## Deployment
Deployment is done using Terraform w/docker provider

```bash
# Deploy applications
terraform -chdir=tf-deploy terraform apply -auto-approve
```

Deploys the following containers:
  * boundary-controller/worker
  * boundary-database (postgres)
  * boundary-database-init
  * boundary-worker (TODO)
  * 1 x adminer instance
  * 3 x demo webservers

Persist database to docker-volume

## Configuration
Configuration is done using Terraform w/boundary provider
```bash
# Configure boundary
terraform -chdir=tf-configure terraform apply -auto-approve
```

## Cleanup
Remove files/resources
```bash
# Cleanup
terraform -chdir=tf-configure terraform destroy -auto-approve
terraform -chdir=tf-deploy terraform destroy -auto-approve
```
