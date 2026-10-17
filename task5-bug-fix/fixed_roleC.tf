# =============================================================================
# ORIGINAL BROKEN CODE (for reference — do not apply)
# =============================================================================
#
# data "aws_iam_policy_document" "roleC_trust" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::000000000000:user/roleB"]   # BUG 1 ← :user/ instead of :role/
#     }
#   }
# }
#
# resource "aws_iam_role" "roleC" {
#   name               = "roleC"
#   assume_role_policy = data.aws_iam_policy_document.roleC_trust.json
# }
#
# resource "aws_iam_role_policy" "roleC_s3" {
#   name = "roleC-s3-access"
#   role = aws_iam_role.roleC.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = "s3:*"
#       Resource = "*"              # BUG 2 ← grants access to ALL S3 buckets, not one
#     }]
#   })
# }

# =============================================================================
# FIXED CODE – two bugs corrected, all names arrise- prefixed
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

# ── FIX 1: Trust the ROLE ARN, not a user ARN ────────────────────────────────
# BEFORE: "arn:aws:iam::000000000000:user/roleB"  ← WRONG (roleB is a Role, not a User)
# AFTER:  "arn:aws:iam::<account_a_id>:role/arrise-roleB"  ← CORRECT
#
# Why it failed: AWS STS does an exact ARN match. The caller presents
# arn:aws:iam::000000000000:role/arrise-roleB but the trust policy listed
# arn:aws:iam::000000000000:user/roleB — these are different strings, so
# STS returns AccessDenied immediately.
data "aws_iam_policy_document" "arrise_roleC_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:role/arrise-roleB"] # FIXED
    }
  }
}

resource "aws_iam_role" "arrise_roleC" {
  name               = "arrise-roleC"
  assume_role_policy = data.aws_iam_policy_document.arrise_roleC_trust.json

  tags = merge(local.common_tags, {
    Name = "arrise-roleC"
  })
}

# ── FIX 2: Scope S3 permissions to a specific named bucket ────────────────────
# BEFORE: Resource = "*"  ← grants s3:* on EVERY bucket in the account
# AFTER:  Two-element list scoped to just arrise-artifacts-bucket
#
# Why it was wrong: The assignment requires "full access to a single named S3 bucket".
# Resource = "*" violates least-privilege and the requirement. A compromised caller
# would have unrestricted S3 access across the entire account.
#
# Two ARNs are required because AWS IAM evaluates bucket-level (s3:ListBucket)
# and object-level (s3:GetObject, s3:PutObject, …) operations against different
# resource namespaces.
resource "aws_iam_role_policy" "arrise_roleC_s3" {
  name = "arrise-roleC-s3-access"
  role = aws_iam_role.arrise_roleC.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "FullAccessToArriseArtifactsBucketOnly"
      Effect = "Allow"
      Action = "s3:*"
      Resource = [ # FIXED – specific bucket only
        "arn:aws:s3:::${var.artifacts_bucket_name}",
        "arn:aws:s3:::${var.artifacts_bucket_name}/*"
      ]
    }]
  })
}

output "arrise_roleC_arn" {
  description = "ARN of the fixed arrise-roleC"
  value       = aws_iam_role.arrise_roleC.arn
}
