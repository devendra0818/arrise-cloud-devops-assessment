variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "owner" {
  description = "Owner tag value"
  type        = string
}

variable "account_a_id" {
  description = "Account A ID (where arrise-roleB lives)"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "The single named S3 bucket that arrise-roleC has full access to"
  type        = string
}
