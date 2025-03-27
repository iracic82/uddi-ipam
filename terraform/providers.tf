# initiate required Providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # or latest stable
  }
}

provider "google" {
  alias   = "gcp_instances"
  project = null
  region  = null
  zone    = null
}



provider "aws" {
  region = "eu-west-1"
  alias = "eu-west-1"
  #profile = "okta-sso"
  #shared_credentials_files = ["./credentials"]
  #profile = "default"
}
provider "aws" {
  region = "eu-west-2"
  alias = "eu-west-2"
  #profile = "okta-sso"
  #shared_credentials_files = ["./credentials"]
  #profile = "default"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
  #profile = "okta-sso"
  #shared_credentials_files = ["./credentials"]
  #profile = "default"
}

provider "aws" {
  region = "eu-west-2"
  alias = "eu-aws"
  #profile = "okta-sso"
  #shared_credentials_files = ["./credentials"]
  #profile = "default"
}

provider "azurerm" {
  
  alias = "eun"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription
  client_id       = var.client
  client_secret   = var.clientsecret
  tenant_id       = var.tenantazure
  #skip_provider_registration = "true"

}
