# Create Public IPs to manage Firewalls
resource "azurerm_public_ip" "fwvm01mgmtpip" {
  name			= "${var.prefix}-fwvm01-mgmt-pip"
  location		= "${azurerm_resource_group.main.location}"
  resource_group_name	= "${azurerm_resource_group.main.name}"
  allocation_method	= "Dynamic"

  tags = {
    Name		= "${var.environment}-fwvm01-mgmt-public-ip"
    environment		= "${var.environment}"
    owner		= "${var.owner}"
    group		= "${var.group}"
    costcenter		= "${var.costcenter}"
    application		= "${var.application}"
  }
}

resource "azurerm_public_ip" "fwvm02mgmtpip" {
  name			= "${var.prefix}-fwvm02-mgmt-pip"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  allocation_method	= "Dynamic"

  tags = {
    Name		= "${var.environment}-fwvm02-mgmt-public-ip"
    environment		= "${var.environment}"
    owner		= "${var.owner}"
    group		= "${var.group}"
    costcenter		= "${var.costcenter}"
    application		= "${var.application}"
  }
}

#Create AV Set
resource "azurerm_availability_set" "fwavset" {
  name                  = "${var.prefix}f5avset"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed               = true
}

# Create Azure fwlb
resource "azurerm_lb" "fwlb" {
  name                  = "${var.prefix}fwlb"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name	= "${azurerm_resource_group.main.name}"

  frontend_ip_configuration {
    name                          = "FW_LoadBalancerFrontEnd"
    subnet_id                     = "${azurerm_subnet.Ext2Sc.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwlb_feip}"
  }
}

resource "azurerm_lb_backend_address_pool" "fw_backend_pool" {
  name                  = "fw_BackendPool1"
  resource_group_name	= "${azurerm_resource_group.main.name}"
  loadbalancer_id       = "${azurerm_lb.fwlb.id}"
}

resource "azurerm_lb_probe" "fwlb_probe" {
  resource_group_name	= "${azurerm_resource_group.main.name}"
  loadbalancer_id       = "${azurerm_lb.fwlb.id}"
  name                  = "tcpProbe"
  protocol              = "tcp"
  port                  = 443
  interval_in_seconds   = 5
  number_of_probes      = 2
}

resource "azurerm_lb_rule" "fwlb_rule1" {
  name                  = "fwLBRule1"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  loadbalancer_id       = "${azurerm_lb.fwlb.id}"
  protocol              = "tcp"
  frontend_port         = 443
  backend_port          = 443
  frontend_ip_configuration_name	= "FW_LoadBalancerFrontEnd"
  enable_floating_ip    	= false
  backend_address_pool_id	= "${azurerm_lb_backend_address_pool.fw_backend_pool.id}"
  idle_timeout_in_minutes       = 5
  probe_id                      = "${azurerm_lb_probe.fwlb_probe.id}"
  depends_on                    = ["azurerm_lb_probe.fwlb_probe"]
}

resource "azurerm_lb_rule" "fwlb_rule2" {
  name                  = "fwLBRule2"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  loadbalancer_id       = "${azurerm_lb.fwlb.id}"
  protocol              = "tcp"
  frontend_port         = 80
  backend_port          = 80
  frontend_ip_configuration_name        = "FW_LoadBalancerFrontEnd"
  enable_floating_ip            = false
  backend_address_pool_id       = "${azurerm_lb_backend_address_pool.fw_backend_pool.id}"
  idle_timeout_in_minutes       = 5
  probe_id                      = "${azurerm_lb_probe.fwlb_probe.id}"
  depends_on                    = ["azurerm_lb_probe.fwlb_probe"]
}

# Create the interfaces for the firewalls
resource "azurerm_network_interface" "fwvm01-mgmt-nic" {
  name                      = "${var.prefix}-fwvm01-mgmt-nic"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.Mgmt.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwvm01mgmt}"
    public_ip_address_id          = "${azurerm_public_ip.fwvm01mgmtpip.id}"
  }

  tags = {
    Name           = "${var.environment}-fwvm01-mgmt-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_network_interface" "fwvm02-mgmt-nic" {
  name                      = "${var.prefix}-fwvm02-mgmt-nic"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.Mgmt.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwvm02mgmt}"
    public_ip_address_id          = "${azurerm_public_ip.fwvm02mgmtpip.id}"
  }

  tags = {
    Name           = "${var.environment}-fwvm02-mgmt-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_network_interface" "fwvm01-ToSC-nic" {
  name                = "${var.prefix}-fwvm01-ToSC-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
  enable_ip_forwarding	    = true
  depends_on          = ["azurerm_lb_backend_address_pool.fw_backend_pool"]

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.Ext2Sc.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwvm01ToSC}"
    primary			  = true
  }

  ip_configuration {
    name                          = "secondary"
    subnet_id                     = "${azurerm_subnet.Ext2Sc.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwvm01ToSC_sec}"
  }

  tags = {
    Name           = "${var.environment}-fwvm01-ToSC-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_network_interface" "fwvm02-ToSC-nic" {
  name                = "${var.prefix}-fwvm02-ToSC-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
  enable_ip_forwarding	    = true
  depends_on          = ["azurerm_lb_backend_address_pool.fw_backend_pool"]

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.Ext2Sc.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwvm02ToSC}"
    primary			  = true
  }

  ip_configuration {
    name                          = "secondary"
    subnet_id                     = "${azurerm_subnet.Ext2Sc.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwvm02ToSC_sec}"
  }

  tags = {
    Name           = "${var.environment}-fwvm02-ToSC-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_network_interface" "fwvm01-FrSC-nic" {
  name                = "${var.prefix}-fwvm01-FrSC-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
  enable_ip_forwarding	    = true
  depends_on          = ["azurerm_lb_backend_address_pool.fw_backend_pool"]

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.Sc2Ext.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwvm01FrSC}"
    primary			  = true
  }

  ip_configuration {
    name                          = "secondary"
    subnet_id                     = "${azurerm_subnet.Sc2Ext.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwvm01FrSC_sec}"
  }

  tags = {
    Name           = "${var.environment}-fwvm01-FrSC-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_network_interface" "fwvm02-FrSC-nic" {
  name                = "${var.prefix}-fwvm02-FrSC-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
  enable_ip_forwarding	    = true
  depends_on          = ["azurerm_lb_backend_address_pool.fw_backend_pool"]

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.Sc2Ext.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwvm02FrSC}"
    primary			  = true
  }

  ip_configuration {
    name                          = "secondary"
    subnet_id                     = "${azurerm_subnet.Sc2Ext.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.fwvm02FrSC_sec}"
  }

  tags = {
    Name           = "${var.environment}-fwvm02-FrSC-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

# Associate the Network Interface to the Firewall BackendPool
resource "azurerm_network_interface_backend_address_pool_association" "bpool_assc_fwvm01" {
  depends_on          = ["azurerm_lb_backend_address_pool.fw_backend_pool", "azurerm_network_interface.fwvm01-ToSC-nic"]
  network_interface_id    = "${azurerm_network_interface.fwvm01-ToSC-nic.id}"
  ip_configuration_name   = "secondary"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.fw_backend_pool.id}"
}

resource "azurerm_network_interface_backend_address_pool_association" "bpool_assc_fwvm02" {
  depends_on          = ["azurerm_lb_backend_address_pool.fw_backend_pool", "azurerm_network_interface.fwvm02-ToSC-nic"]
  network_interface_id    = "${azurerm_network_interface.fwvm02-ToSC-nic.id}"
  ip_configuration_name   = "secondary"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.fw_backend_pool.id}"
}


data "template_file" "fwvm01_do_json" {
  template = "${file("${path.module}/firewall.json")}"

  vars = {
    #Uncomment the following line for BYOL
    regkey	    = "${var.license3}"

    host1	          = "${var.fwhost1_name}"
    host2	          = "${var.fwhost2_name}"
    local_host      = "${var.fwhost1_name}"
    local_selfip1   = "${var.fwvm01ToSC}"
    remote_selfip   = "${var.fwvm02ToSC}"
    local_selfip2   = "${var.fwvm01FrSC}"
    gateway	        = "${local.Sc2Ext_gw}"
    dns_server	    = "${var.dns_server}"
    ntp_server	    = "${var.ntp_server}"
    timezone	      = "${var.timezone}"
    admin_user      = "${var.uname}"
    admin_password  = "${var.upassword}"
  }
}

data "template_file" "fwvm02_do_json" {
  template = "${file("${path.module}/firewall.json")}"

  vars = {
    #Uncomment the following line for BYOL
    regkey	    = "${var.license4}"

    host1	          = "${var.fwhost2_name}"
    host2	          = "${var.fwhost1_name}"
    local_host      = "${var.fwhost2_name}"
    local_selfip1   = "${var.fwvm02ToSC}"
    remote_selfip   = "${var.fwvm01ToSC}"
    local_selfip2   = "${var.fwvm02FrSC}"
    gateway	        = "${local.Sc2Ext_gw}"
    dns_server	    = "${var.dns_server}"
    ntp_server	    = "${var.ntp_server}"
    timezone	      = "${var.timezone}"
    admin_user      = "${var.uname}"
    admin_password  = "${var.upassword}"
  }
}


# Create Firewall NVA's
resource "azurerm_virtual_machine" "fwvm01" {
  name                         = "${var.prefix}-fwvm01"
  location                     = "${azurerm_resource_group.main.location}"
  depends_on                   = ["azurerm_virtual_machine.backendvm"]
  resource_group_name          = "${azurerm_resource_group.main.name}"
  primary_network_interface_id = "${azurerm_network_interface.fwvm01-mgmt-nic.id}"
  network_interface_ids        = ["${azurerm_network_interface.fwvm01-mgmt-nic.id}", "${azurerm_network_interface.fwvm01-ToSC-nic.id}", "${azurerm_network_interface.fwvm01-FrSC-nic.id}"]
  vm_size                      = "${var.instance_type}"
  availability_set_id          = "${azurerm_availability_set.fwavset.id}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "f5-networks"
    offer     = "${var.product}"
    sku       = "${var.image_name}"
    version   = "${var.bigip_version}"
  }

  storage_os_disk {
    name              = "${var.prefix}fwvm01-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "80"
  }

  os_profile {
    computer_name  = "${var.prefix}fwvm01"
    admin_username = "${var.uname}"
    admin_password = "${var.upassword}"
    custom_data    = "${data.template_file.vm_onboard.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  plan {
    name          = "${var.image_name}"
    publisher     = "f5-networks"
    product       = "${var.product}"
  }

  tags = {
    Name           = "${var.environment}-fwvm01"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_virtual_machine" "fwvm02" {
  name                         = "${var.prefix}-fwvm02"
  location                     = "${azurerm_resource_group.main.location}"
  depends_on                   = ["azurerm_virtual_machine.backendvm"]
  resource_group_name          = "${azurerm_resource_group.main.name}"
  primary_network_interface_id = "${azurerm_network_interface.fwvm02-mgmt-nic.id}"
  network_interface_ids        = ["${azurerm_network_interface.fwvm02-mgmt-nic.id}", "${azurerm_network_interface.fwvm02-ToSC-nic.id}", "${azurerm_network_interface.fwvm02-FrSC-nic.id}"]
  vm_size                      = "${var.instance_type}"
  availability_set_id          = "${azurerm_availability_set.fwavset.id}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "f5-networks"
    offer     = "${var.product}"
    sku       = "${var.image_name}"
    version   = "${var.bigip_version}"
  }

  storage_os_disk {
    name              = "${var.prefix}fwvm02-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "80"
  }

  os_profile {
    computer_name  = "${var.prefix}fwvm02"
    admin_username = "${var.uname}"
    admin_password = "${var.upassword}"
    custom_data    = "${data.template_file.vm_onboard.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  plan {
    name          = "${var.image_name}"
    publisher     = "f5-networks"
    product       = "${var.product}"
  }

  tags = {
    Name           = "${var.environment}-fwvm02"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

#Create startup scripts
resource "azurerm_virtual_machine_extension" "fwvm01_run_startup_cmd" {
  name                 = "${var.environment}_fwvm01_run_startup_cmd"
  depends_on           = ["azurerm_virtual_machine.fwvm01"]
  location             = "${var.region}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.fwvm01.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"
  #publisher            = "Microsoft.Azure.Extensions"
  #type                 = "CustomScript"
  #type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "bash /var/lib/waagent/CustomData"
    }
  SETTINGS

  tags = {
    Name           = "${var.environment}_fwvm01_startup_cmd"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_virtual_machine_extension" "fwvm02_run_startup_cmd" {
  name                 = "${var.environment}_fwvm02-run_startup_cmd"
  depends_on           = ["azurerm_virtual_machine.fwvm02"]
  location             = "${var.region}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.fwvm02.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"
  #publisher            = "Microsoft.Azure.Extensions"
  #type                 = "CustomScript"
  #type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "bash /var/lib/waagent/CustomData"
    }
  SETTINGS

  tags = {
    Name           = "${var.environment}_fwvm02_startup_cmd"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "null_resource" "fwvm01_DO" {
  depends_on	= ["azurerm_virtual_machine_extension.fwvm01_run_startup_cmd"]
  # Running DO REST API
  provisioner "local-exec" {
    command = <<-EOF
      #!/bin/bash
      curl -k -X ${var.rest_do_method} https://${data.azurerm_public_ip.fwvm01mgmtpip.ip_address}${var.rest_do_uri} -u ${var.uname}:${var.upassword} -d @${var.rest_fwvm01_do_file}
      x=1; while [ $x -le 30 ]; do STATUS=$(curl -k -X GET https://${data.azurerm_public_ip.fwvm01mgmtpip.ip_address}/mgmt/shared/declarative-onboarding/task -u ${var.uname}:${var.upassword}); if ( echo $STATUS | grep "OK" ); then break; fi; sleep 10; x=$(( $x + 1 )); done
      sleep 120
    EOF
  }
}

resource "null_resource" "fwvm02_DO" {
  depends_on    = ["azurerm_virtual_machine_extension.fwvm02_run_startup_cmd"]
  # Running DO REST API
  provisioner "local-exec" {
    command = <<-EOF
      #!/bin/bash
      curl -k -X ${var.rest_do_method} https://${data.azurerm_public_ip.fwvm02mgmtpip.ip_address}${var.rest_do_uri} -u ${var.uname}:${var.upassword} -d @${var.rest_fwvm02_do_file}
      x=1; while [ $x -le 30 ]; do STATUS=$(curl -k -X GET https://${data.azurerm_public_ip.fwvm02mgmtpip.ip_address}/mgmt/shared/declarative-onboarding/task -u ${var.uname}:${var.upassword}); if ( echo $STATUS | grep "OK" ); then break; fi; sleep 10; x=$(( $x + 1 )); done
      sleep 120
    EOF
  }
}

## OUTPUTS ###
data "azurerm_public_ip" "fwvm01mgmtpip" {
  name                = "${azurerm_public_ip.fwvm01mgmtpip.name}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  depends_on          = ["azurerm_virtual_machine.fwvm01"]
}
data "azurerm_public_ip" "fwvm02mgmtpip" {
  name                = "${azurerm_public_ip.fwvm02mgmtpip.name}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  depends_on          = ["azurerm_virtual_machine.fwvm02"]
}

output "fwvm01_id" { value = "${azurerm_virtual_machine.fwvm01.id}"  }
output "fwvm01_mgmt_private_ip" { value = "${azurerm_network_interface.fwvm01-mgmt-nic.private_ip_address}" }
output "fwvm01_mgmt_public_ip" { value = "${data.azurerm_public_ip.fwvm01mgmtpip.ip_address}" }
output "fwvm01_ToSC_private_ip" { value = "${azurerm_network_interface.fwvm01-ToSC-nic.private_ip_address}" }
output "fwvm01_FrSC_private_ip" { value = "${azurerm_network_interface.fwvm01-FrSC-nic.private_ip_address}" }

output "fwvm02_id" { value = "${azurerm_virtual_machine.fwvm02.id}"  }
output "fwvm02_mgmt_private_ip" { value = "${azurerm_network_interface.fwvm02-mgmt-nic.private_ip_address}" }
output "fwvm02_mgmt_public_ip" { value = "${data.azurerm_public_ip.fwvm02mgmtpip.ip_address}" }
output "fwvm02_ToSC_private_ip" { value = "${azurerm_network_interface.fwvm02-ToSC-nic.private_ip_address}" }
output "fwvm02_FrSC_private_ip" { value = "${azurerm_network_interface.fwvm02-FrSC-nic.private_ip_address}" }