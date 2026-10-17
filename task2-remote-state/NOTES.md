# Task 2 Remote State and Locking

Task 1 already uses the shared `arrise-devops-tfstate` S3 bucket. This task reuses that
bucket for its own state key and enables the S3 backend lockfile with `use_lockfile = true`.
Terraform writes a temporary `.tflock` object beside the state object while a state-writing
operation is in progress. No DynamoDB table is configured or needed for this lockfile.

With independent local state files, two people can plan from different snapshots, both
change the same infrastructure, and leave their state files disagreeing with AWS. A shared
S3 state object avoids separate state copies, and its lockfile prevents concurrent
Terraform operations from writing that state at the same time. Locking only coordinates
Terraform runs that use this backend; it does not prevent manual AWS changes.

Initialize this task with:

```bash
terraform init -backend-config=env/sandbox/backend.tfvars
```

HashiCorp has deprecated DynamoDB-based S3 locking in favor of S3 lockfiles. The backend
uses S3 locking directly, so this task does not provision a DynamoDB lock table.
