terraform {
  required_version = ">= 1.0.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">=2.7.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0" # Replace with the appropriate version of the random provider
    }
  }

  backend "s3" {
    bucket  = "terraform-state-poc-vllm"
    region  = "us-east-1"
    key     = "state/ai-on-eks/terraform.tfstate"
    encrypt = true
    profile = "vllm-admin" #Profile SSO
  }
}
