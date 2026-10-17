# env/sandbox/backend.tfvars
# ─────────────────────────────────────────────────────────────
# Usage:
#   terraform init -backend-config=env/sandbox/backend.tfvars
# ─────────────────────────────────────────────────────────────

bucket       = "arrise-devops-tfstate"
key          = "task3-iam/sandbox/terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true # S3 native locking requires Terraform 1.10
