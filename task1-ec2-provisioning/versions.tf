terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend config is intentionally empty here.
  # Values are injected at `terraform init` time via:
  #   terraform init -backend-config=env/sandbox/backend.tfvars
  backend "s3" {}
}
