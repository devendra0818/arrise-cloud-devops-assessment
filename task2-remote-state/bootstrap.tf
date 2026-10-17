# bootstrap.tf
# ─────────────────────────────────────────────────────────────────────────────
# PURPOSE: Creates the S3 bucket and DynamoDB table that will be used as the
# Terraform remote backend. These resources MUST exist before the S3 backend
# block in versions.tf can be initialised.
#
# WORKFLOW:
#   Step 1 – Temporarily comment out the backend "s3" {} block in versions.tf
#             (or leave it empty; init will use local backend automatically).
#   Step 2 – terraform init
#   Step 3 – terraform apply -var-file=env/sandbox/variables.tfvars
#             (this creates the bucket + DynamoDB table)
#   Step 4 – Uncomment the backend "s3" {} block in versions.tf.
#   Step 5 – terraform init -backend-config=env/sandbox/backend.tfvars -migrate-state
#             (migrates local state into the new S3 bucket)
# ─────────────────────────────────────────────────────────────────────────────

locals {
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

# ── S3 bucket for Terraform state ─────────────────────────────────────────────
resource "aws_s3_bucket" "arrise_terraform_state" {
  bucket        = var.state_bucket_name # e.g. "arrise-devops-tfstate"
  force_destroy = false

  tags = merge(local.common_tags, {
    Name = var.state_bucket_name
  })
}

resource "aws_s3_bucket_versioning" "arrise_terraform_state" {
  bucket = aws_s3_bucket.arrise_terraform_state.id
  versioning_configuration {
    status = "Enabled" # Enables rollback to a previous state file version
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "arrise_terraform_state" {
  bucket = aws_s3_bucket.arrise_terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "arrise_terraform_state" {
  bucket                  = aws_s3_bucket.arrise_terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── DynamoDB table for state locking ──────────────────────────────────────────
resource "aws_dynamodb_table" "arrise_terraform_lock" {
  name         = var.lock_table_name # e.g. "arrise-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" # Must be "LockID" — Terraform requirement

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.common_tags, {
    Name = var.lock_table_name
  })
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "state_bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = aws_s3_bucket.arrise_terraform_state.bucket
}

output "lock_table_name" {
  description = "Name of the DynamoDB state lock table"
  value       = aws_dynamodb_table.arrise_terraform_lock.name
}
