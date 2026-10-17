# env/sandbox/variables.tfvars
# ─────────────────────────────────────────────────────────────
# Usage:
#   terraform plan  -var-file=env/sandbox/variables.tfvars
#   terraform apply -var-file=env/sandbox/variables.tfvars
# ─────────────────────────────────────────────────────────────

aws_region  = "us-east-1"
environment = "sandbox"
owner       = "arrise-devops-team"

# Account A – where arrise-roleB lives
account_a_id = "000000000000"
account_b_id = "111111111111"

# The one named bucket arrise-roleC is allowed to access
artifacts_bucket_name = "arrise-artifacts-bucket"
