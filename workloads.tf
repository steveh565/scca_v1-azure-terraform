# Create the Interface for the App1 server
resource "azurerm_network_interface" "app1-backend01-ext-nic" {
  name                = "${var.prefix}-app1-backend01-ext-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.App1.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.backend01ext}"
    primary			  = true
  }

  tags = {
    foo            = "bar"
    f5_cloud_failover_label = "${var.prefix}-${var.application}"
    f5_cloud_failover_nic_map = "internal"
  }
}

# backend VM
resource "azurerm_virtual_machine" "app1-backendvm" {
    name                  = "${var.prefix}-app1-backendvm"
    location                     = "${azurerm_resource_group.main.location}"
    resource_group_name          = "${azurerm_resource_group.main.name}"

    network_interface_ids = ["${azurerm_network_interface.app1-backend01-ext-nic.id}"]
    vm_size               = "Standard_B1s"

    storage_os_disk {
        name              = "app1backendOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "app1backend01"
        admin_username = "${var.uname}"
        admin_password = "${var.upassword}"
        custom_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              docker run --restart unless-stopped --net=host -p 80:80 -p 443:443 -d vulnerables/web-dvwa
              EOF
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

  tags = {
    application    = "app1"
  }
}

# Create the Interface for the App2 server
resource "azurerm_network_interface" "app2-backend01-ext-nic" {
  name                = "${var.prefix}-app2-backend01-ext-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.App2.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.backend02ext}"
    primary			  = true
  }

  tags = {
    foo            = "bar"
    f5_cloud_failover_label = "${var.prefix}-app2"
    f5_cloud_failover_nic_map = "internal"
  }
}


# backend VM
resource "azurerm_virtual_machine" "app2-backendvm" {
    name                  = "${var.prefix}-app2-backendvm"
    location                     = "${azurerm_resource_group.main.location}"
    resource_group_name          = "${azurerm_resource_group.main.name}"

    network_interface_ids = ["${azurerm_network_interface.app2-backend01-ext-nic.id}"]
    vm_size               = "Standard_B1s"

    storage_os_disk {
        name              = "app2backendOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "app2-backend01"
        admin_username = "${var.uname}"
        admin_password = "${var.upassword}"
        custom_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              docker run --restart unless-stopped --net=host -p 80:80 -p 443:443 -d vulnerables/web-dvwa
              EOF
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

  tags = {
    application    = "app2"
  }
}