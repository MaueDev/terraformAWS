provider "aws" {
  region  = var.RegionAll
}


terraform {
  backend "s3" {
    bucket = "backendtesteth"
    key    = "terraforms.tfstate"
    region = "sa-east-1"
  }
}