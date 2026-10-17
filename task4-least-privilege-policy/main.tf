locals {
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

# ── Custom least-privilege IAM policy for the arrise-ci user ──────────────────
resource "aws_iam_policy" "arrise_ci_policy" {
  name        = "arrise-ci-least-privilege-policy"
  description = "Least-privilege policy for arrise-ci: ECR push, ECS deploy, S3 read-only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. ECR authentication – must be Resource:* (account-level API, not repo-scoped)
      {
        Sid      = "ECRAuthentication"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      # 2. ECR push – scoped to the specific arrise ECR repository
      {
        Sid    = "ECRPushToArriseRepo"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:${var.account_id}:repository/${var.ecr_repository_name}"
      },
      # 3. ECS – register a new task definition revision and update the service
      {
        Sid    = "ECSDeployArriseService"
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = [
          "arn:aws:ecs:${var.aws_region}:${var.account_id}:service/${var.ecs_cluster_name}/${var.ecs_service_name}",
          "arn:aws:ecs:${var.aws_region}:${var.account_id}:task-definition/${var.ecs_task_family}:*"
        ]
      },
      # 4. iam:PassRole – required for ECS task definitions; scoped by service condition
      {
        Sid    = "ECSPassRole"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          "arn:aws:iam::${var.account_id}:role/${var.ecs_task_execution_role_name}",
          "arn:aws:iam::${var.account_id}:role/${var.ecs_task_role_name}"
        ]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },
      # 5. S3 read-only – build artifacts bucket (no write or delete)
      {
        Sid    = "S3ReadOnlyArriseArtifacts"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.artifacts_bucket_name}/*"
      },
      {
        Sid      = "ListArriseArtifacts"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::${var.artifacts_bucket_name}"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "arrise-ci-least-privilege-policy"
  })
}

# Attach the custom policy to the arrise-ci user
resource "aws_iam_user_policy_attachment" "arrise_ci_attach" {
  user       = "arrise-ci"
  policy_arn = aws_iam_policy.arrise_ci_policy.arn
}

output "arrise_ci_policy_arn" {
  description = "ARN of the arrise-ci least-privilege policy"
  value       = aws_iam_policy.arrise_ci_policy.arn
}
