terraform {
  required_version = ">=1.9"
  required_providers {
    aws = "~> 5.64.0"
  }
}
provider "aws" {
  region = "us-east-1"
}