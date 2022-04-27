/////////////////////////////////////////////////
// Unmanaged/external resources (data)
/////////////////////////////////////////////////

data "azurerm_subscription" "CURRENT" {}

data "azurerm_resource_group" "MAIN" {
  name = local.resource_group_name
}

/////////////////////////////////////////////////
// Network resources
/////////////////////////////////////////////////

resource "azurerm_virtual_network" "MAIN" {
  name                = local.vnet_name
  address_space       = local.vnet_address_space
  location            = data.azurerm_resource_group.MAIN.location
  resource_group_name = data.azurerm_resource_group.MAIN.name
}

resource "azurerm_subnet" "MAIN" {
  name                 = local.subnet_name
  address_prefixes     = local.subnet_prefixes
  virtual_network_name = azurerm_virtual_network.MAIN.name
  resource_group_name  = data.azurerm_resource_group.MAIN.name
}

/////////////////////////////////////////////////
// Loadbalancer resources
/////////////////////////////////////////////////

resource "azurerm_public_ip" "MAIN" {
  name                = format("%s-%s",local.prefix,"PublicIPAddress")
  allocation_method   = "Static"
  location            = data.azurerm_resource_group.MAIN.location
  resource_group_name = data.azurerm_resource_group.MAIN.name
}

resource "azurerm_lb" "MAIN" {
  name = format("%s-%s",local.prefix,"LoadBalancer")

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.MAIN.id
  }
  
  location            = data.azurerm_resource_group.MAIN.location
  resource_group_name = data.azurerm_resource_group.MAIN.name
}

resource "azurerm_lb_backend_address_pool" "MAIN" {
  name            = format("%s-%s",local.prefix,"BackEndAddressPool")
  loadbalancer_id = azurerm_lb.MAIN.id
}

resource "azurerm_lb_nat_pool" "SSH" {
  name                = format("%s-%s",local.prefix,"PoolSSH")
  protocol            = "Tcp"
  frontend_ip_configuration_name = "PublicIPAddress"
  frontend_port_start = 2200
  frontend_port_end   = 2299
  backend_port        = 22
  loadbalancer_id     = azurerm_lb.MAIN.id
  resource_group_name = data.azurerm_resource_group.MAIN.name
}

resource "azurerm_lb_probe" "HTTP" {
  name            = format("%s-%s",local.prefix,"ProbeHTTP")
  port            = 80
  loadbalancer_id = azurerm_lb.MAIN.id
}

resource "azurerm_lb_rule" "HTTP" {
  name                           = format("%s-%s",local.prefix,"RuleHTTP")
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "PublicIPAddress"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [ azurerm_lb_backend_address_pool.MAIN.id ]
  loadbalancer_id                = azurerm_lb.MAIN.id
  probe_id                       = azurerm_lb_probe.HTTP.id
}

/////////////////////////////////////////////////
// Security resources
/////////////////////////////////////////////////

// https://docs.microsoft.com/en-us/azure/virtual-network/application-security-groups
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_security_group
resource "azurerm_application_security_group" "MAIN" {
  name                = format("%s-%s",local.prefix,"ApplicationSecurityGroup")
  location            = data.azurerm_resource_group.MAIN.location
  resource_group_name = data.azurerm_resource_group.MAIN.name
}

// https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "MAIN" {
  name                = format("%s-%s",local.prefix,"NetworkSecurityGroup")
  location            = data.azurerm_resource_group.MAIN.location
  resource_group_name = data.azurerm_resource_group.MAIN.name
}

resource "azurerm_subnet_network_security_group_association" "MAIN" {
  subnet_id = azurerm_subnet.MAIN.id
  network_security_group_id = azurerm_network_security_group.MAIN.id
}

resource "azurerm_network_security_rule" "INBOUND_SSH" {
  name                        = format("%s-%s",local.prefix,"InboundRuleSSH")
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_application_security_group_ids = [ azurerm_application_security_group.MAIN.id ]
  network_security_group_name = azurerm_network_security_group.MAIN.name
  resource_group_name         = data.azurerm_resource_group.MAIN.name
}

resource "azurerm_network_security_rule" "INBOUND_HTTP" {
  name                        = format("%s-%s",local.prefix,"InboundRuleHTTP")
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_application_security_group_ids = [ azurerm_application_security_group.MAIN.id ]
  network_security_group_name = azurerm_network_security_group.MAIN.name
  resource_group_name         = data.azurerm_resource_group.MAIN.name
}

/////////////////////////////////////////////////
// Compute resources
/////////////////////////////////////////////////

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set
resource "azurerm_linux_virtual_machine_scale_set" "MAIN" {
  name      = format("%s",local.prefix)
  instances = local.scale
  sku       = "Standard_B1s" //az vm list-skus --location norwayeast --output table
  
  admin_username = "superman"
  admin_password = "L0g1n234"
  disable_password_authentication = false

  //az vm image list --location norwayeast --publisher Canonical --sku 22_04-lts-gen2 --output table --all
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
  }

  network_interface {
    name = format("%s-%s",local.prefix,"nic")
    primary = true
    #network_security_group_id = azurerm_network_security_group.MAIN.id

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.MAIN.id
      
      application_security_group_ids         = [ azurerm_application_security_group.MAIN.id ]
      load_balancer_backend_address_pool_ids = [ azurerm_lb_backend_address_pool.MAIN.id ]
      load_balancer_inbound_nat_rules_ids    = [ azurerm_lb_nat_pool.SSH.id ]
    }
  }

  resource_group_name = data.azurerm_resource_group.MAIN.name
  location = data.azurerm_resource_group.MAIN.location
}
