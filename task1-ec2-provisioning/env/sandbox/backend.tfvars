# env/sandbox/backend.tfvars
# ─────────────────────────────────────────────────────────────
# Usage:
#   terraform init -backend-config=env/sandbox/backend.tfvars
# ─────────────────────────────────────────────────────────────

bucket  = "arrise-devops-tfstate"
key     = "task1-ec2/sandbox/terraform.tfstate"
region  = "us-east-1"
encrypt = true
