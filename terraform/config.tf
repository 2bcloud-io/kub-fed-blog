terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.56"
    }
  }
}

provider "aws" {
  alias  = "first"
  region = "us-east-1"
}

provider "aws" {
  alias  = "second"
  region = "us-west-2"
}