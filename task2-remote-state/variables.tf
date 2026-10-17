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

variable "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  type        = string
}
