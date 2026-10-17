# env/sandbox/backend.tfvars
# ─────────────────────────────────────────────────────────────
# Usage:
#   terraform init -backend-config=env/sandbox/backend.tfvars
# ─────────────────────────────────────────────────────────────

bucket         = "arrise-devops-tfstate"
key            = "task2-remote-state/sandbox/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "arrise-terraform-state-lock"
