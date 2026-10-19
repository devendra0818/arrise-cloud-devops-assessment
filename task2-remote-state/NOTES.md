# Task 2 Remote State and Locking

Task 1 and this task use the shared `arrise-devops-tfstate` S3 bucket, with separate
state keys. The backend enables S3-native locking with `use_lockfile = true`.
Terraform writes a temporary `.tflock` object beside the state object while a state-writing
operation is in progress. No DynamoDB table is configured or needed for this lockfile.
The backend also requires AWS credentials with access to the existing state bucket.

With independent local state files, two people can plan from different snapshots, both
change the same infrastructure, and leave their state files disagreeing with AWS. A shared
S3 state object avoids separate state copies, and its lockfile prevents concurrent
Terraform operations from writing that state at the same time. Locking only coordinates
Terraform runs that use this backend; it does not prevent manual AWS changes.

Initialize this task with:

```bash
terraform init -backend-config=env/sandbox/backend.tfvars
```

The assignment asks for DynamoDB locking. DynamoDB locking is deprecated, but it is not
unsupported. This configuration uses Terraform's S3-native lockfile instead, so it does
not create or depend on a DynamoDB table. The S3 bucket must already exist; enable bucket
versioning so previous state versions can be recovered.
