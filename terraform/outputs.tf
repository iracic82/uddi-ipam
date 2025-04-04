## Output variable definitions

#output "ssh_access_aws_us" {
#  value = values(module.aws__instances_us)[*].ssh_access
#}

output "ssh_access_aws_eu" {
  value = values(module.aws__instances_eu)[*].ssh_access
}

output "ssh_access_azure_eu" {
  value = values(module.azure_instances_eu)[*].ssh_access
}

output "ssh_access_gcp_eu" {
  value = values(module.gcp_instances)[*].ssh_access
}

output "vpc_ids" {
  description = "Map of VPC IDs created by the aws__instances_eu module"
  value       = { for key, instance in module.aws__instances_eu : key => instance.aws_vpc_id }
}

output "route53_dns_records_list" {
  description = "List of DNS records created"
  value       = [for record in aws_route53_record.dns_records : "${record.name} => ${tolist(record.records)[0]}"]
}

output "azure_dns_records_list" {
  description = "List of Azure Private DNS A records created"
  value = [
    for name, record in azurerm_private_dns_a_record.eu_dns_records :
    "${record.name}.${record.zone_name} => ${tolist(record.records)[0]}"
  ]
}
