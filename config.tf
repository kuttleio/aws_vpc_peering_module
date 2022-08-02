terraform {
  required_version = ">= 1.2.4"
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"    
    }
  }
}

provider "aws" {
  alias  = "requester"
  region = var.aws_requester_provider_region

  assume_role {
    role_arn     = var.aws_requester_role_arn
    session_name = "aws_vpc_peering_requester_connection-terraform"
  }
}

provider "aws" {
  alias  = "accepter"
  region = var.aws_accepter_provider_region

  assume_role {
    role_arn     = var.aws_accepter_role_arn
    session_name = "aws_vpc_peering_accepter_connection-terraform"
  }
}
