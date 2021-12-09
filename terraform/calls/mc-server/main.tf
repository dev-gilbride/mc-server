provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.68"
    }
  }
  required_version = ">= 1.0.11"

  backend "s3" {
    bucket = "terrafun-tf-backend"
    key    = "mc-server"
    region = "us-west-2"
  }
}

module "mc-server" {
  source      = "../../modules/minecraft-server"
  device_name = "/dev/sdh"
  key_name    = "mc"
  availability_zone = "us-west-2c"

}

