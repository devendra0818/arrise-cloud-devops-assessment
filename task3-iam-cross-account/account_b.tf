########################################################################
# ACCOUNT B (var.account_b_id) – arrise-roleC and the protected S3 bucket
########################################################################

# ── arrise-roleC trust policy: ONLY arrise-roleB from Account A may assume ────
# Trust the specific role ARN, NOT the account root – see NOTES.md for why.
data "aws_iam_policy_document" "arrise_roleC_trust" {
  provider = aws.account_b

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:role/arrise-roleB"]
    }
  }
}

resource "aws_iam_role" "arrise_roleC" {
  provider           = aws.account_b
  name               = "arrise-roleC"
  assume_role_policy = data.aws_iam_policy_document.arrise_roleC_trust.json
  tags               = merge(local.common_tags, { Description = "Full access to arrise-artifacts bucket; assumable only by arrise-roleB" })
}

# ── arrise-roleC permissions: full access to ONE specific S3 bucket only ──────
resource "aws_iam_role_policy" "arrise_roleC_s3" {
  provider = aws.account_b
  name     = "arrise-roleC-s3-access"
  role     = aws_iam_role.arrise_roleC.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "FullAccessToArriseArtifactsBucket"
      Effect = "Allow"
      Action = "s3:*"
      Resource = [
        "arn:aws:s3:::${var.artifacts_bucket_name}",
        "arn:aws:s3:::${var.artifacts_bucket_name}/*"
      ]
    }]
  })
}

# ── The named S3 bucket that arrise-roleC has full access to ──────────────────
resource "aws_s3_bucket" "arrise_artifacts" {
  provider      = aws.account_b
  bucket        = var.artifacts_bucket_name
  force_destroy = false

  tags = merge(local.common_tags, {
    Name = var.artifacts_bucket_name
  })
}

resource "aws_s3_bucket_versioning" "arrise_artifacts" {
  provider = aws.account_b
  bucket   = aws_s3_bucket.arrise_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "arrise_artifacts" {
  provider                = aws.account_b
  bucket                  = aws_s3_bucket.arrise_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── Outputs ────────────────────────────────────────────────────────────────────
output "arrise_roleC_arn" {
  description = "ARN of arrise-roleC in Account B"
  value       = aws_iam_role.arrise_roleC.arn
}

output "arrise_roleB_arn" {
  description = "ARN of arrise-roleB in Account A"
  value       = aws_iam_role.arrise_roleB.arn
}
