# ./provider.tf

# provider
provider "aws" {
  profile = var.profile
  region  = var.region
}

# terraformバージョン
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.46"
    }
  }
}
