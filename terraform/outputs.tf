## Output variable definitions

output "ssh_access_aws_us" {
  value = values(module.aws__instances_us)[*].ssh_access
}

output "ssh_access_aws_eu" {
  value = values(module.aws__instances_eu)[*].ssh_access
}

output "ssh_access_azure_eu" {
  value = values(module.azure_instances_eu)[*].ssh_access
}
