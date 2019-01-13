# Execute the foolowing steps to get the id's
# 
# az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
# az account show --query "{ subscription_id: id }"

variable "location" {
  default = "Central US"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    client_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    client_secret   = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    tenant_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

resource "azurerm_resource_group" "rsg" {
    name = "terraform"
    location = "${var.location}"
    tags {
    environment = "Test"
  }
}

resource "azurerm_virtual_network" "tfvnet" {
    name = "terraformvnet"
    resource_group_name = "${azurerm_resource_group.rsg.name}"
    address_space = ["192.168.0.0/16"]
    location = "${var.location}"

}

resource "azurerm_subnet" "terraformcompute" {
    name                 = "terraformcompute"
  virtual_network_name = "${azurerm_virtual_network.tfvnet.name}"
   resource_group_name = "${azurerm_resource_group.rsg.name}"
  address_prefix       = "192.168.0.0/24"

}


resource "azurerm_public_ip" "publicip" {
    count = 2
    name = "terraformip-${count.index}"
    resource_group_name = "${azurerm_resource_group.rsg.name}"
    location = "${var.location}"
    public_ip_address_allocation = "dynamic"

}



#
resource "azurerm_network_interface" "terraformnic" {
  count               = 2
  name                = "terraformnic${count.index}"
   resource_group_name = "${azurerm_resource_group.rsg.name}"
  location = "${var.location}"

  ip_configuration {
    name                          = "terraformipconfig-${count.index}"
    subnet_id                     = "${azurerm_subnet.terraformcompute.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${length(azurerm_public_ip.publicip.*.id) > 0 ? element(concat(azurerm_public_ip.publicip.*.id, list("")), count.index) : ""}"
    #public_ip_address_id          =  ["${element(azurerm_public_ip.publicip.*.id, count.index)}"]
  }
}

resource "azurerm_virtual_machine" "myvm" {
    count                 = 2
    name                  = "terraformdevops${count.index}"
    resource_group_name   = "${azurerm_resource_group.rsg.name}"
    location = "${var.location}"
    network_interface_ids = ["${element(azurerm_network_interface.terraformnic.*.id, count.index)}"]
    vm_size               = "Standard_B1s"
   

     storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name              = "myosdisk${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

  os_profile {
        computer_name  = "terraformdevops"
        admin_username = "tribhi"
        admin_password = "motherindia@123"
    }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}


