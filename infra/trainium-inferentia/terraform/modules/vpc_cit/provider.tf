provider "aws" {
  region = "us-east-1"
  profile = "vllm-admin"
}

terraform {
	required_providers {
		aws = {
	    version = ">= 3.72"
		}
  }
}
