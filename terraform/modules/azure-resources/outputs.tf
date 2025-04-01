# Print Azure Instance Public
output "azure_vm_public_ip" {
  value = azurerm_public_ip.ip_1.ip_address
}

output "ssh_access" {
  value = "${var.azure_instance_name} - ${azurerm_linux_virtual_machine.vm_1.private_ip_address} =>  ssh -i '${var.azure_server_key_pair_name}.pem' linuxuser@${azurerm_public_ip.ip_1.ip_address}"
}

output "azure_vnet_id" {
  description = "ID of the created Azure Virtual Network"
  value       = azurerm_virtual_network.vnet_1.id
}

output "azure_resource_group_name" {
  description = "The name of the Azure Resource Group"
  value       = azurerm_resource_group.rg_iac.name
}

output "azure_vnet_name" {
  value = azurerm_virtual_network.vnet_1.name
}
output "azure_subnet_name" {
  value = azurerm_subnet.subnet_1.name
}

output "azure_location" {
  value = var.azure_location
}
output "enable_peering" {
  value = var.enable_peering
}

