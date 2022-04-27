# LINUX SCALE-SET WITH LOAD-BALANCER

## How to use this example

```bash
# Login to your Azure subscription
az login

# Deploy resources
terraform init
terraform validate
terraform apply -auto-approve

# Connect to resource. Find values in Azure Portal
ssh superman@<public-ip-address> -p <loadbalancer-nat-port>

# Install docker & start example webserver
curl -fsSL get.docker.com|sh
sudo usermod -aG docker superman
sudo docker run --rm -d traefik/whoami:latest

# Verify webpage is shown at http://<public-ip-address>

# Cleanup resources
terraform destroy -auto-approve
```

## Default credentials
* Admin username: superman
* Admin password: L0g1n234
