terraform {
# @NOTE!!! MUST use encrypted s3 bucket for remote state never use local but for demo purposes it will do
#   backend "s3" {
#     bucket                      = "001-di-works-terraform-state"
#     key                         = "rosscdh/devops-challenge/terraform.tfstate"
#     region                      = "ap-southeast-2"
#     profile                     = "SHARED"
#     skip_metadata_api_check     = true
#     skip_region_validation      = true
#     skip_credentials_validation = true
#   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.4.6"
}


provider "aws" {
  alias   = "ap-southeast-2"
  region  = "ap-southeast-2"
  profile = "default"
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "default"
}