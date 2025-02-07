# Print Azure Instance Public
output "azure_vm_public_ip" {
  value = azurerm_public_ip.ip_1.ip_address
}

output "ssh_access" {
  value = "${var.azure_instance_name} - ${azurerm_linux_virtual_machine.vm_1.private_ip_address} =>  ssh -i '${var.azure_server_key_pair_name}.pem' linuxuser@${azurerm_public_ip.ip_1.ip_address}"
}
