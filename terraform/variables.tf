variable aws_region {
    type = list(string)
    description = "Region for AWS resoruces"
}

variable vpc_cidr {
  type = list(string)
  description = "valid subnets to assign to server"
}

variable subnet_cidr {
  type = list(string)
  description = "valid subnets to assign to server"
}

variable prosimo_cidr {
  type = list(string)
  description = "valid subnets to assign to server"
}

variable private_ip {
  description = "Static Private IP"
  type = list(string)
}

variable prosimo_token {
  type = string
  description = "valid prosimo token - from MSP Portal"
}


variable prosimo_teamName {
  type = string
  description = "valid name of the tenant"
}

variable subscription {
  type = string
  description = "azure subscription id"
}

variable client {
  type = string
  description = "azure client id"
}

variable clientsecret {
  type = string
  description = "azure client secret"
}

variable tenantazure {
  type = string
  description = "azure tenant id"
}


variable Access_Key_AWS {
  type = string
  description = "valid AWS Key"
}

variable Access_Secret_AWS {
  type = string
  description = "valid AWS Secret"
}
variable cloud_type {
  type = string

}

variable "US_East_FrontEnd" {
  type = map(object({
    aws_vpc_name                = string
    igw_name                    = string
    rt_name                     = string
    aws_subnet_name             = string
    private_ip                  = string
    aws_ec2_name                = string
    aws_ec2_key_pair_name       = string
    aws_vpc_cidr                = string
    aws_subnet_cidr             = string
  }))
}

variable "EU_West_FrontEnd" {
  type = map(object({
    aws_vpc_name                = string
    igw_name                    = string
    rt_name                     = string
    aws_subnet_name             = string
    private_ip                  = string
    aws_ec2_name                = string
    aws_ec2_key_pair_name       = string
    aws_vpc_cidr                = string
    aws_subnet_cidr             = string
  }))
}

variable "North_EU_AppSvcs_VNets" {
  type = map(object({
    azure_resource_group        = string
    azure_location              = string
    azure_vnet_name             = string
    azure_subnet_name           = string
    azure_instance_name         = string
    azure_server_key_pair_name  = string
    azure_private_ip            = string
    azure_vm_size               = string
    azure_admin_username        = string
    azure_subnet_cidr           = string
    azure_vnet_cidr             = string
    azure_admin_password        = string

  }))
}

variable "North_US_AppSvcs_VNets" {
  type = map(object({
    azure_resource_group        = string
    azure_location              = string
    azure_vnet_name             = string
    azure_subnet_name           = string
    azure_instance_name         = string
    azure_server_key_pair_name  = string
    azure_private_ip            = string
    azure_vm_size               = string
    azure_admin_username        = string
    azure_subnet_cidr           = string
    azure_vnet_cidr             = string
    azure_admin_password        = string

  }))
}
