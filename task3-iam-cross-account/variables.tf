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
  description = "AWS Account ID for Account A"
  type        = string
}

variable "account_b_id" {
  description = "AWS Account ID for Account B"
  type        = string
}

variable "account_a_profile" {
  description = "AWS CLI profile authenticated to Account A"
  type        = string
}

variable "account_b_profile" {
  description = "AWS CLI profile authenticated to Account B"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket in Account B that roleC manages"
  type        = string
}
