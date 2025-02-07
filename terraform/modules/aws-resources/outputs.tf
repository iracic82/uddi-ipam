# Print AWS Instance Public
output "aws_ec2_public_ip" {
  value = aws_instance.ec2_linux.public_ip
}

output "aws_eip_public_ip" {
  value = aws_eip.eip.public_ip
}

output "aws_vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.vpc1.id
}

output "subnet_id" {
  description = "The ID of the created subnet"
  value       = aws_subnet.subnet1.id
}

output "aws_vpc_name" {
  description = "The name of the created VPC"
  value       = var.aws_vpc_name
}

output "aws_vpc_cidr" {
  description = "The CIDR block of the created VPC"
  value       = var.aws_vpc_cidr
}

output "aws_subnet_cidr" {
  description = "The CIDR block of the created subnet"
  value       = var.aws_subnet_cidr
}

output "rt_id" {
  description = "The ID of the created Route Table"
  value       = aws_route_table.rt_vpc1.id
}

output "rt_association_id" {
  description = "The ID of the Route Table Association"
  value       = aws_route_table_association.rt_association_vpc1.id
}

output "ssh_access" {
  value = "${var.aws_ec2_name} - ${aws_instance.ec2_linux.private_ip} => ssh -i '${var.aws_ec2_key_pair_name}.pem' ec2-user@${aws_eip.eip.public_ip}"
}