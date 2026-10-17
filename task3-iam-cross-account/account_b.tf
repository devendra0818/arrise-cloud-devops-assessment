resource "aws_iam_role" "arrise_roleC" {
  provider = aws.account_b
  name     = "arrise-roleC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = "arn:aws:iam::${var.account_a_id}:role/arrise-roleB" }
    }]
  })

  tags = merge(local.common_tags, { Name = "arrise-roleC" })
}

resource "aws_iam_role_policy" "arrise_roleC_s3" {
  provider = aws.account_b
  name     = "arrise-roleC-s3-access"
  role     = aws_iam_role.arrise_roleC.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "s3:*"
      Resource = [
        aws_s3_bucket.arrise_artifacts.arn,
        "${aws_s3_bucket.arrise_artifacts.arn}/*"
      ]
    }]
  })
}

resource "aws_s3_bucket" "arrise_artifacts" {
  provider      = aws.account_b
  bucket        = var.artifacts_bucket_name
  force_destroy = false

  tags = merge(local.common_tags, { Name = var.artifacts_bucket_name })
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

output "arrise_roleC_arn" {
  description = "ARN of arrise-roleC in Account B"
  value       = aws_iam_role.arrise_roleC.arn
}

output "arrise_roleB_arn" {
  description = "ARN of arrise-roleB in Account A"
  value       = aws_iam_role.roleB.arn
}
