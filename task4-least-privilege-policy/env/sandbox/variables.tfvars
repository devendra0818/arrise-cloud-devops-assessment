# env/sandbox/variables.tfvars
# ─────────────────────────────────────────────────────────────
# Usage:
#   terraform plan  -var-file=env/sandbox/variables.tfvars
#   terraform apply -var-file=env/sandbox/variables.tfvars
# ─────────────────────────────────────────────────────────────

aws_region  = "us-east-1"
environment = "sandbox"
owner       = "arrise-devops-team"

# Replace with your actual Account A ID
account_id = "000000000000"

# ECR repository that arrise-ci can push Docker images to
ecr_repository_name = "arrise-app"

# ECS resources arrise-ci can deploy to
ecs_cluster_name = "arrise-cluster"
ecs_service_name = "arrise-service"
ecs_task_family  = "arrise-task"

# IAM roles that arrise-ci is allowed to pass to ECS (and ONLY to ECS)
ecs_task_execution_role_name = "arrise-ecs-task-execution-role"
ecs_task_role_name           = "arrise-ecs-task-role"

# S3 bucket for build artifacts – read-only access
artifacts_bucket_name = "arrise-build-artifacts"
