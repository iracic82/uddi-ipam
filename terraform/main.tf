

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


# Create Linux and Networking Infrastructure in GCP

module "gcp_instances" {
  source   = "./modules/gcp-resources"
  for_each = var.GCP_EU_North
  providers = {
    google = google.gcp_instances
  }

  project         = each.value["gcp_project"]
  region          = each.value["gcp_region"]
  zone            = each.value["gcp_zone"]

  vpc_name        = each.value["gcp_vpc_name"]
  subnet_name     = each.value["gcp_subnet_name"]
  subnet_cidr     = each.value["gcp_subnet_cidr"]
  private_ip      = each.value["gcp_private_ip"]
  instance_name   = each.value["gcp_instance_name"]

  startup_script = each.value["startup_script"] # just the string path
  ssh_user        = each.value["ssh_user"]

  labels          = each.value["labels"]
}



resource "aws_ec2_transit_gateway" "us" {
provider = aws.us-east-1
description = "AIG-US-TGW"
tags = {
    Name = "AIG-US-TGW"
  }
}




resource "aws_ec2_transit_gateway" "eu" {
provider = aws.eu-aws
description = "EU-TGW"
tags = {
    Name = "EU-TGW"
  }
}



# Create TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "tgw_rt" {
  provider = aws.us-east-1
  transit_gateway_id = aws_ec2_transit_gateway.us.id
  tags = {
    Name = "EU-TGW-RouteTable"
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



resource "aws_route53_zone" "private_zone" {
  provider = aws.eu-west-2
  name     = var.route53_domain_name
  comment  = "Private hosted zone for Infoblox"

  dynamic "vpc" {
    for_each = { for key, data in module.aws__instances_eu : key => data.aws_vpc_id }  # Extract only VPC IDs
    content {
      vpc_id     = vpc.value
      vpc_region = var.aws_region[0]
    }
  }

  tags = {
    Name          = "InfobloxPrivateZone"
    ResourceOwner = "iracic@infoblox.com"
  }
}

resource "aws_route53_record" "dns_records" {

  provider = aws.eu-west-2
  count   = var.enable_dns_records ? length(keys(var.EU_West_FrontEnd)) : 0
  zone_id = aws_route53_zone.private_zone.id

  name = lookup(var.EU_West_FrontEnd[element(keys(var.EU_West_FrontEnd), count.index)], "app_fqdn", "default.infoblox.local")
  type = "A"
  ttl  = 300

  records = [
    lookup(
      var.EU_West_FrontEnd[element(keys(var.EU_West_FrontEnd), count.index)],
      "private_ip",
      "10.0.0.1"
    )
  ]
}

resource "aws_s3_bucket" "infoblox_poc" {

  provider = aws.eu-west-2
  bucket = "infoblox-poc-iracic"

  tags = {
    Name          = "Infoblox POC Bucket"
    Environment   = "POC"
    ResourceOwner = "iracic@infoblox.com"
  }
}

resource "aws_s3_bucket_public_access_block" "infoblox_poc" {

  provider = aws.eu-west-2
  bucket = aws_s3_bucket.infoblox_poc.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_access" {

  provider = aws.eu-west-2
  bucket = aws_s3_bucket.infoblox_poc.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.infoblox_poc.bucket}/uploads/*"
    }
  ]
}
EOF
}

resource "aws_s3_object" "uploaded_image" {

  provider = aws.eu-west-2
  bucket = aws_s3_bucket.infoblox_poc.id
  key    = "uploads/image.png"
  source = "/home/ec2-user/Infoblox-PoC/images/image.png"

  tags = {
    Name          = "Infoblox Image"
    ResourceOwner = "iracic@infoblox.com"
  }
}

resource "aws_route53_record" "s3_cname" {

  provider = aws.eu-west-2
  zone_id = aws_route53_zone.private_zone.id  # Use the correct hosted zone
  name    = "infobloxs3.infolab.com"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_s3_bucket.infoblox_poc.bucket}.s3.eu-west-2.amazonaws.com"]
}
