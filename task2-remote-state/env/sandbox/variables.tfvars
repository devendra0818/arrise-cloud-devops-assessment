# env/sandbox/variables.tfvars
# ─────────────────────────────────────────────────────────────
# Usage:
#   terraform plan  -var-file=env/sandbox/variables.tfvars
#   terraform apply -var-file=env/sandbox/variables.tfvars
# ─────────────────────────────────────────────────────────────

aws_region  = "us-east-1"
environment = "sandbox"
owner       = "arrise-devops-team"

# The bucket name matches the one created by this bootstrap config
state_bucket_name = "arrise-devops-tfstate"
lock_table_name   = "arrise-terraform-state-lock"
