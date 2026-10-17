# Task 5 — Find and Fix the Bug

## Fixes

1. The trust policy named `user/roleB`, but `roleB` is an IAM role. AWS therefore
   would not match the caller to the trusted principal, and `AssumeRole` would be
   denied. The fixed trust policy names `arn:aws:iam::<Account A>:role/arrise-roleB`.
2. The permissions policy used `s3:*` with `Resource = "*"`, which grants access
   across all S3 buckets. The fixed policy keeps the requested full S3 access but
   scopes it to the one configured bucket. The bucket ARN covers bucket actions;
   the `/*` ARN covers its objects.

The second issue was an excessive-permissions bug rather than a Terraform syntax
error. The trust policy and the `roleB` identity policy must both allow the
cross-account `AssumeRole` call.
