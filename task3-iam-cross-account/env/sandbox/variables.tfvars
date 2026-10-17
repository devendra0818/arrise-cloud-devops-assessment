# env/sandbox/variables.tfvars
# ─────────────────────────────────────────────────────────────
# Usage:
#   terraform plan  -var-file=env/sandbox/variables.tfvars
#   terraform apply -var-file=env/sandbox/variables.tfvars
# ─────────────────────────────────────────────────────────────

aws_region  = "us-east-1"
environment = "sandbox"
owner       = "arrise-devops-team"

# Replace with real AWS Account IDs
account_a_id = "000000000000" # Account A – IAM users, groups, roleA, roleB
account_b_id = "111111111111" # Account B – roleC, S3 artifact bucket

# The single named S3 bucket that arrise-roleC has full access to
artifacts_bucket_name = "arrise-artifacts-bucket"
