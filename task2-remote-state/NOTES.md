# Task 2 Remote State and Locking

With separate local state files, two engineers can plan from different snapshots, both
create the same resources, and leave different state files behind. The state can then
disagree with the resources in AWS. A shared local file also does not provide reliable
coordination across machines.

This configuration stores the authoritative state in S3 and enables bucket versioning
and server-side encryption. Terraform uses the DynamoDB table with the `LockID` partition
key to coordinate operations. A concurrent state-changing run waits or fails while the
lock is held, preventing simultaneous state writes. Locking only coordinates Terraform
runs using this backend; it does not prevent manual AWS changes. Terraform releases the
lock after an operation, though a stale lock may need manual recovery.

The state bucket and lock table must exist before the S3 backend can initialize. Bootstrap
them with `terraform init -backend=false` and `terraform apply -var-file=env/sandbox/variables.tfvars`,
then initialize the configured backend and migrate the local state as shown in the README.
