# Create a resource group
resource "azurerm_resource_group" "count-rg" {
  name     = "${var.prefix}-rg"
  location = var.region
}

# Create a virtual network
resource "azurerm_virtual_network" "count-vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.count-rg.location
  resource_group_name = azurerm_resource_group.count-rg.name
}

# Create subnet
resource "azurerm_subnet" "count-subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.count-rg.name
  virtual_network_name = azurerm_virtual_network.count-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a network security group
resource "azurerm_network_security_group" "count-nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.count-rg.location
  resource_group_name = azurerm_resource_group.count-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG to subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.count-subnet.id
  network_security_group_id = azurerm_network_security_group.count-nsg.id
}

# Create public IP
resource "azurerm_public_ip" "count-publicIP" {
  count               = 3
  name                = "${var.prefix}-publicip-${count.index}"
  location            = azurerm_resource_group.count-rg.location
  resource_group_name = azurerm_resource_group.count-rg.name
  allocation_method   = "Dynamic"
}

# Create a network interface
resource "azurerm_network_interface" "count-nic" {
  count               = 3
  name                = "${var.prefix}-nic-${count.index}"
  location            = azurerm_resource_group.count-rg.location
  resource_group_name = azurerm_resource_group.count-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.count-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.count-publicIP[count.index].id
  }
}

# Create a virtual machine
resource "azurerm_linux_virtual_machine" "count-vm" {
  count                           = 3
  name                            = "${var.prefix}-${count.index}"
  resource_group_name             = azurerm_resource_group.count-rg.name
  location                        = azurerm_resource_group.count-rg.location
  size                            = var.vm_size
  admin_username                  = var.admin
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.count-nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8_4"
    version   = "latest"
  }
}

# Output the Public IP Addresses of the VMs
output "public_ip_address" {
  value = azurerm_public_ip.count-publicIP.*.ip_address
}
