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

variable "account_id" {
  description = "AWS Account ID where CI resources reside"
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository the CI user can push to"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "ecs_task_family" {
  description = "Name (family) of the ECS task definition"
  type        = string
}

variable "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution IAM role"
  type        = string
}

variable "ecs_task_role_name" {
  description = "Name of the ECS task IAM role"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket used for build artifacts (read-only)"
  type        = string
}
