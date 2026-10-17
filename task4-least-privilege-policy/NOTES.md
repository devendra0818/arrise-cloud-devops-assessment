# NOTES.md – Task 4: Least-Privilege Policy Writing

## What the CI user needs and what I included

| Action                                  | IAM Actions included                                                           | Scope                                      |
|-----------------------------------------|--------------------------------------------------------------------------------|--------------------------------------------|
| Push Docker image to ECR                | `ecr:GetAuthorizationToken` (account-level) + 5 push-specific ECR actions      | Specific repository: `arrise-app`          |
| Deploy new ECS task definition/service  | `ecs:RegisterTaskDefinition`, `ecs:UpdateService`, `ecs:DescribeServices/TaskDef` | Specific cluster + service + task family   |
| Read-only S3 for build artifacts        | `s3:GetObject`, `s3:GetObjectVersion`, `s3:ListBucket`                         | Specific bucket: `arrise-build-artifacts`  |
| Pass IAM roles to ECS                   | `iam:PassRole` (with condition: `ecs-tasks.amazonaws.com`)                     | Only the two specific ECS role ARNs         |

---

## What I deliberately left out and why

### 1. `s3:PutObject`, `s3:DeleteObject`, `s3:PutBucketPolicy` on the artifacts bucket
- The task says **read (not write)**.
- A CI pipeline that reads build artifacts should never be able to overwrite or delete them.
- This prevents a compromised CI job from tampering with the artifact store (supply-chain attack).

### 2. `ecr:DeleteRepository`, `ecr:BatchDeleteImage`, `ecr:SetRepositoryPolicy`
- A CI pipeline only needs to **push** images, not manage the repository itself.
- Allowing deletes could cause a CI bug (or malicious actor) to wipe the entire image history.

### 3. `ecs:DeleteService`, `ecs:DeleteCluster`, `ecs:StopTask`
- The pipeline deploys by updating a service's task definition; it should never be able to
  tear down the cluster or stop running tasks outside of a deployment.

### 4. `ecs:*` (wildcard) or `s3:*`
- Managed policies like `PowerUserAccess` or wildcards such as `s3:*` violate least-privilege.
- Even if it's tempting to use `AmazonECS_FullAccess`, it includes dozens of unrelated actions
  (auto-scaling, CloudWatch alarms, etc.) that a CI pipeline has no business touching.

### 5. `iam:CreateRole`, `iam:AttachRolePolicy`, `iam:PutRolePolicy`
- A CI pipeline must never be able to create or modify IAM roles or policies.
- If a CI job could elevate its own privileges, a compromised pipeline could gain
  admin access to the entire account.

### 6. `ecr:GetAuthorizationToken` scoped to a resource
- This action **cannot** be scoped to a specific repository; it is account-level only.
- I left `Resource: "*"` for this single action, which is an unavoidable AWS constraint,
  and documented it clearly in the policy's comment field.

### 7. `sts:AssumeRole` for cross-account roles
- The CI user for Task 4 operates only in Account A.
- Giving it the ability to assume roles in other accounts would violate least-privilege.
- Cross-account access is handled by `roleB` (Task 3) which is a separate, purpose-built role.

---

## `iam:PassRole` — Why it's included and scoped

`ecs:UpdateService` and `ecs:RegisterTaskDefinition` require the caller to be able to
`iam:PassRole` for the **ECS task execution role** and **ECS task role** to the ECS service.
Without this, Terraform/AWS CLI would return `AccessDenied: ... is not authorized to pass this role`.

I scoped it with a **condition** (`iam:PassedToService: ecs-tasks.amazonaws.com`) so that
the CI user can only pass these roles to ECS — not to EC2, Lambda, or any other service.
