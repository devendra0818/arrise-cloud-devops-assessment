# Task 4 — Least-Privilege CI Policy

The custom policy is attached to the Task 3 CI user, `ci`.

- **ECR:** Allows Docker push actions on the configured repository. `GetAuthorizationToken`
  uses `Resource = "*"` because AWS does not support repository-level scoping for it.
- **ECS:** Allows registering task definitions for the configured family and updating
  the configured service only to a revision in that family. It can describe that service.
  `ecs:DescribeTaskDefinition` uses `Resource = "*"`
  because ECS does not support resource-level scoping for that action. `iam:PassRole`
  is limited to the two ECS task roles and to the ECS tasks service.
- **S3:** Allows listing and reading objects from the configured artifacts bucket.

Deliberately excluded: S3 writes/deletes, ECR repository administration or image
deletion, ECS service/cluster creation or deletion, and IAM role or policy changes.
The pipeline can deploy using the existing ECS task roles, but cannot create or
change IAM permissions. The cluster, service, task roles, repository, and buckets
must already exist and match the values in the sandbox variable file. This avoids broader managed policies such as
`PowerUserAccess`.

`ci-policy.json` shows the same policy with sandbox example resource names. Replace
the example Account A ID before using that standalone JSON in a real account.
