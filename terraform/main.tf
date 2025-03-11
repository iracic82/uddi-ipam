

# Create EC2 and Networking Infrastructure in AWS

module "aws__instances_eu" {
  source = "./modules/aws-resources"
  providers         = {   
  aws = aws.eu-west-2
  }
  for_each              = var.EU_West_FrontEnd
  aws_region            = var.aws_region[0]
  aws_vpc_name          = each.value["aws_vpc_name"]
  aws_subnet_name       = each.value["aws_subnet_name"]
  rt_name               = each.value["rt_name"]
  igw_name              = each.value["igw_name"]
  private_ip            = each.value["private_ip"]
  tgw                   = "false"
  internet              = "true"
  aws_ec2_name          = each.value["aws_ec2_name"]
  aws_ec2_key_pair_name = each.value["aws_ec2_key_pair_name"]

  aws_vpc_cidr    = each.value["aws_vpc_cidr"]
  aws_subnet_cidr = each.value["aws_subnet_cidr"]
 
}

module "aws__instances_us" {
  source = "./modules/aws-resources"
  providers         = { 
  aws = aws.us-east-1
  }
  for_each              = var.US_East_FrontEnd
  aws_region            = var.aws_region[1]
  aws_vpc_name          = each.value["aws_vpc_name"]
  aws_subnet_name       = each.value["aws_subnet_name"]
  rt_name               = each.value["rt_name"]
  igw_name              = each.value["igw_name"]
  private_ip            = each.value["private_ip"]
  tgw                   = "false"
  internet              = "false"
  aws_ec2_name          = each.value["aws_ec2_name"]
  aws_ec2_key_pair_name = each.value["aws_ec2_key_pair_name"]

  aws_vpc_cidr    = each.value["aws_vpc_cidr"]
  aws_subnet_cidr = each.value["aws_subnet_cidr"]

}

# Create Linux and Networking Infrastructure in Azure

module "azure_instances_us" {
  source = "./modules/azure-resources"
  providers = {
  azurerm = azurerm.eun
  }
  for_each             = var.North_US_AppSvcs_VNets
  azure_resource_group = each.value["azure_resource_group"]
  azure_location       = "East US"
  azure_vnet_name      = each.value["azure_vnet_name"]
  azure_subnet_name    = each.value["azure_subnet_name"]
  azure_instance_name  = each.value["azure_instance_name"]
  azure_private_ip     = each.value["azure_private_ip"]
  azure_server_key_pair_name  = each.value["azure_server_key_pair_name"]
  azure_vm_size        = "Standard_DS1_v2"
  azure_admin_username = "linuxuser"
  azure_admin_password = "admin123"

  azure_subnet_cidr    = each.value["azure_subnet_cidr"]
  azure_vnet_cidr      = each.value["azure_vnet_cidr"]
}


module "azure_instances_eu" {
  source = "./modules/azure-resources"
  providers = {
  azurerm = azurerm.eun
  }
  for_each             = var.North_EU_AppSvcs_VNets
  azure_resource_group = each.value["azure_resource_group"]
  azure_location       = "North Europe"
  azure_vnet_name      = each.value["azure_vnet_name"]
  azure_subnet_name    = each.value["azure_subnet_name"]
  azure_instance_name  = each.value["azure_instance_name"]
  azure_private_ip     = each.value["azure_private_ip"]
  azure_server_key_pair_name  = each.value["azure_server_key_pair_name"]
  azure_vm_size        = "Standard_DS1_v2"
  azure_admin_username = "linuxuser"
  azure_admin_password = "admin123"

  azure_subnet_cidr    = each.value["azure_subnet_cidr"]
  azure_vnet_cidr      = each.value["azure_vnet_cidr"]
}





resource "aws_ec2_transit_gateway" "us" {
provider = aws.us-east-1
description = "AIG-US-TGW"
tags = {
    Name = "AIG-US-TGW"
  }
}

/*
# Onboard Azure resources

module "azure_instances_us" {
  source = "./modules/azure-resources"
  providers = {
  azurerm = azurerm.eun
  }
  for_each             = var.North_EU_AppSvcs_VNets
  azure_resource_group = each.value["azure_resource_group"]
  azure_location       = "North Europe"
  azure_vnet_name      = each.value["azure_vnet_name"]
  azure_subnet_name    = each.value["azure_subnet_name"]
  azure_instance_name  = each.value["azure_instance_name"]
  azure_private_ip     = each.value["azure_private_ip"]
  azure_server_key_pair_name  = each.value["azure_server_key_pair_name"]
  azure_vm_size        = "Standard_DS1_v2"
  azure_admin_username = "linuxuser"
  azure_admin_password = "admin123"

  azure_subnet_cidr    = each.value["azure_subnet_cidr"]
  azure_vnet_cidr      = each.value["azure_vnet_cidr"]
}

/*
# Onboard Networks to Prosimo Fabric

module "network_eu" {
  source = "./modules/prosimo-network"
  prosimo_teamName = var.prosimo_teamName
  prosimo_token = var.prosimo_token
  name         = "WEB_Subnet_EU"
  region       = var.aws_region[0]
  subnets      = var.subnet_cidr[0]
  connectivity_type  = "vpc-peering"
  placement    = "Workload VPC"
  cloud        = "AWS"
  cloud_type   = "public"
  connectType  = "private"
  vpc          = module.aws__instances_eu.aws_vpc_id
  cloudNickname= "Prosimo"
  decommission = "false"
  onboard      = "true"
  depends_on   = [ module.prosimo_resource ] 
}



resource "aws_ec2_transit_gateway" "eu" {
provider = aws.eu-aws
description = "AIG-EU-TGW"
tags = {
    Name = "AIG-EU-TGW"
  }
}



# Create Virtual Instance and Networking Infrastructre in Azure
module "azure_instances_1" {
  source = "./modules/azure-resources"

  azure_resource_group = "demo_IaC_basic"
  azure_location       = "North Europe"
  azure_vnet_name      = "vnet_1"
  azure_subnet_name    = "subnet_1"
  azure_instance_name  = "vm_1"
  azure_vm_size        = "Standard_DS1_v2"
  azure_admin_username = "$test"
  azure_admin_password = "Test2022"

  azure_subnet_cidr = "10.0.0.0/16"
  azure_vnet_cidr   = "10.0.0.0/24"
}
*/

# Create TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "tgw_rt" {
  provider = aws.us-east-1
  transit_gateway_id = aws_ec2_transit_gateway.us.id
  tags = {
    Name = "AIG-US-TGW-RouteTable"
  }
}

# Associate VPC1 Route Table with TGW Route Table
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_association" {
  provider = aws.us-east-1
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
}

# Attach ONLY WebSvcsProdUs1 (VPC1) to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  provider = aws.us-east-1
  subnet_ids          = [module.aws__instances_us["VPC1"].subnet_id]
  transit_gateway_id  = aws_ec2_transit_gateway.us.id
  vpc_id              = module.aws__instances_us["VPC1"].aws_vpc_id

  appliance_mode_support = "enable"
  dns_support            = "enable"
  ipv6_support           = "disable"

  tags = {
    Name = "${module.aws__instances_us["VPC1"].aws_vpc_name}-TGW-Attachment"
  }
}

# Add a route in VPC1's Route Table to send traffic to TGW
resource "aws_route" "tgw_route_vpc1" {
  provider = aws.us-east-1
  route_table_id         = module.aws__instances_us["VPC1"].rt_id
  destination_cidr_block = "10.10.0.0/16"  # Adjust for inter-VPC communication
  transit_gateway_id     = aws_ec2_transit_gateway.us.id
}


