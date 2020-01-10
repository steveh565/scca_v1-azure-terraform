# Create a Virtual Network within the Resource Group
resource "azurerm_virtual_network" "main" {
  name			= "${var.prefix}-PAZ"
  address_space		= ["${var.cidr}"]
  resource_group_name	= "${azurerm_resource_group.main.name}"
  location		= "${azurerm_resource_group.main.location}"
}

# Create a Virtual Network within the Resource Group
resource "azurerm_virtual_network" "spoke" {
  name                  = "${var.prefix}-spoke"
  address_space         = ["${var.app-cidr}"]
  resource_group_name   = "${azurerm_resource_group.main.name}"
  location              = "${azurerm_resource_group.main.location}"
}

# Create a Virtual Network within the Resource Group
resource "azurerm_virtual_network" "app2-spoke" {
  name                  = "${var.prefix}-app2-spoke"
  address_space         = ["${var.app2-cidr}"]
  resource_group_name   = "${azurerm_resource_group.main.name}"
  location              = "${azurerm_resource_group.main.location}"
}

# Create the Mgmt Subnet within the Paz Virtual Network
resource "azurerm_subnet" "Mgmt" {
  name			= "Mgmt"
  virtual_network_name	= "${azurerm_virtual_network.main.name}"
  resource_group_name	= "${azurerm_resource_group.main.name}"
  address_prefix	= "${var.subnets["subnet1"]}"
}

# Create the External Subnet within the Paz Virtual Network
resource "azurerm_subnet" "External" {
  name			= "External"
  virtual_network_name	= "${azurerm_virtual_network.main.name}"
  resource_group_name	= "${azurerm_resource_group.main.name}"
  address_prefix	= "${var.subnets["subnet2"]}"
}

# Create the External-To-ServiceChain Subnet within the Paz Virtual Network
resource "azurerm_subnet" "Ext2Sc" {
  name			= "Ext2Sc"
  virtual_network_name	= "${azurerm_virtual_network.main.name}"
  resource_group_name	= "${azurerm_resource_group.main.name}"
  address_prefix	= "${var.subnets["subnet3"]}"
}

# Create the External-From-ServiceChain Subnet within the Paz Virtual Network
resource "azurerm_subnet" "Sc2Ext" {
  name			= "Sc2Ext"
  virtual_network_name	= "${azurerm_virtual_network.main.name}"
  resource_group_name	= "${azurerm_resource_group.main.name}"
  address_prefix	= "${var.subnets["subnet4"]}"
}

# Create the Internal Subnet within the Paz Virtual Network
resource "azurerm_subnet" "Internal" {
  name			= "Internal"
  virtual_network_name	= "${azurerm_virtual_network.main.name}"
  resource_group_name	= "${azurerm_resource_group.main.name}"
  address_prefix	= "${var.subnets["subnet5"]}"
}

# Create the Internal-To-ServiceChain Subnet within the Paz Virtual Network
resource "azurerm_subnet" "Int2Sc" {
  name			= "Int2Sc"
  virtual_network_name	= "${azurerm_virtual_network.main.name}"
  resource_group_name	= "${azurerm_resource_group.main.name}"
  address_prefix	= "${var.subnets["subnet6"]}"
}

# Create the Inernal-From-ServiceChain Subnet within the Paz Virtual Network
resource "azurerm_subnet" "Sc2Int" {
  name			= "Sc2Int"
  virtual_network_name	= "${azurerm_virtual_network.main.name}"
  resource_group_name	= "${azurerm_resource_group.main.name}"
  address_prefix	= "${var.subnets["subnet7"]}"
}

# Create the Inernal-ALB frontend Subnet within the Paz Virtual Network
resource "azurerm_subnet" "ALB2Internal" {
  name			= "ALB2Internal"
  virtual_network_name	= "${azurerm_virtual_network.main.name}"
  resource_group_name	= "${azurerm_resource_group.main.name}"
  address_prefix	= "${var.subnets["subnet8"]}"
}

# Create the App1 Subnet within the Spoke Virtual Network
resource "azurerm_subnet" "App1" {
  name                  = "App1"
  virtual_network_name  = "${azurerm_virtual_network.spoke.name}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  address_prefix        = "${var.app-subnets["subnet1"]}"
}

# Create the App1 Subnet within the Spoke Virtual Network
resource "azurerm_subnet" "App2" {
  name                  = "App2"
  virtual_network_name  = "${azurerm_virtual_network.app2-spoke.name}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  address_prefix        = "${var.app2-subnets["subnet1"]}"
}

# Obtain Gateway IP for each Subnet
locals {
  depends_on = ["azurerm_subnet.Mgmt", "azurerm_subnet.External"]
  mgmt_gw		 = "${cidrhost(azurerm_subnet.Mgmt.address_prefix, 1)}"
  ext_net    = "${var.subnets["subnet2"]}"
  ext_gw		 = "${cidrhost(azurerm_subnet.External.address_prefix, 1)}"
  Sc2Ext_gw  = "${cidrhost(azurerm_subnet.Sc2Ext.address_prefix, 1)}"
  Ext2Sc_gw  = "${cidrhost(azurerm_subnet.Ext2Sc.address_prefix, 1)}"
  app1_gw    = "${cidrhost(azurerm_subnet.App1.address_prefix, 1)}"
  app1_net    = "${var.app-subnets["subnet1"]}"
  app1_net_gw    = "${cidrhost(azurerm_subnet.Internal.address_prefix, 1)}"
}

# Create Network Peerings
resource "azurerm_virtual_network_peering" "PazToSpoke" {
  name                      = "${var.prefix}-PazToSpoke"
  depends_on                = ["azurerm_virtual_machine.app1-backendvm"]
  resource_group_name       = "${azurerm_resource_group.main.name}"
  virtual_network_name      = "${azurerm_virtual_network.main.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.spoke.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "SpokeToPAZ" {
  name                      = "${var.prefix}-SpokeToPAZ"
  depends_on                = ["azurerm_virtual_machine.app1-backendvm"]
  resource_group_name       = "${azurerm_resource_group.main.name}"
  virtual_network_name      = "${azurerm_virtual_network.spoke.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.main.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# Create Routing Tables with UDRs
resource "azurerm_route_table" "Ext2Sc-rt" {
  name                = "${var.prefix}-Ext2Sc-rt"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${var.location}"
  depends_on          = ["azurerm_lb.fwlb", "azurerm_network_interface.f5vm01-ToSC-nic", "azurerm_network_interface.f5vm01-FrSC-nic"]
  /*
  route {
    name                   = "MGMT_VNET-route"
    address_prefix         = "10.96.120.0/21"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.96.120.4"
  }
  */
  route {
    name           = "sslo_traffic_route"
    address_prefix = "${azurerm_subnet.External.address_prefix}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fwlb_feip}"
  }
  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.f5vm01ToSC_sec}"
  }
  tags = {
    Name           = "${var.environment}-Ext2Sc-rt"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_subnet_route_table_association" "Ext2Sc-rt-assoc" {
  subnet_id      = "${azurerm_subnet.Ext2Sc.id}"
  route_table_id = "${azurerm_route_table.Ext2Sc-rt.id}"
  depends_on     = ["azurerm_route_table.Ext2Sc-rt", "azurerm_subnet.Ext2Sc"]
}

resource "azurerm_route_table" "Sc2Ext-rt" {
  name                = "${var.prefix}-Sc2Ext-rt"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${var.location}"
  depends_on          = ["azurerm_lb.fwlb", "azurerm_network_interface.f5vm01-ToSC-nic", "azurerm_network_interface.f5vm01-FrSC-nic"]
  /*
  route {
    name                   = "MGMT_VNET-route"
    address_prefix         = "10.96.120.0/21"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.96.120.4"
  }
  */
  route {
    name           = "sslo_traffic_route"
    address_prefix = "${azurerm_subnet.External.address_prefix}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.f5vm01FrSC_sec}"
  }
  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.f5vm01ToSC_sec}"
  }
  tags = {
    Name           = "${var.environment}-Sc2Ext-rt"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_subnet_route_table_association" "Sc2Ext-rt-assoc" {
  subnet_id      = "${azurerm_subnet.Sc2Ext.id}"
  route_table_id = "${azurerm_route_table.Sc2Ext-rt.id}"
  depends_on     = ["azurerm_route_table.Sc2Ext-rt", "azurerm_subnet.Sc2Ext"]
}


# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_HTTPS"
    description                = "Allow HTTPS access"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_RDP"
    description                = "Allow RDP access"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_APP_HTTPS"
    description                = "Allow HTTPS access"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name           = "${var.environment}-bigip-sg"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}
