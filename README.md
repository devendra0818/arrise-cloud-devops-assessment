# Arrise Cloud DevOps Assessment

> **Terraform state bucket:** `arrise-devops-tfstate`
> **Naming:** EC2 and supporting resources use descriptive names; Task 3 uses the exact IAM names in the assignment.
> **Structure:** Industry-standard environment-driven layout (`env/sandbox/`)

---

## Project Layout

```
arrise-cloud-devops-assessment/
│
├── task1-ec2-provisioning/
│   ├── versions.tf               # Terraform + provider version constraints; empty backend "s3" {}
│   ├── provider.tf               # AWS provider (region from variable)
│   ├── variables.tf              # Declarations only – no defaults
│   ├── main.tf                   # Calls reusable EC2 module
│   ├── local.tf                  # Shared tags and lifecycle grouping
│   ├── outputs.tf                # instance_ids and instance_private_ips maps
│   ├── NOTES.md                  # Why arrise-db-server is prevent_destroy=true
│   ├── modules/
│   │   └── ec2_instance/         # Reusable EC2 instance implementation
│   └── env/
│       └── sandbox/
│           ├── backend.tfvars    # S3 bucket and key
│           └── variables.tfvars  # AMI, subnet, instance map values
│
├── task2-remote-state/
│   ├── versions.tf               # S3 backend with S3-native lockfile
│   ├── NOTES.md                  # Local-state race and remote-lock explanation
│   └── env/sandbox/backend.tfvars
│
├── task3-iam-cross-account/
│   ├── versions.tf
│   ├── provider.tf               # Dual-account aliases (account_a, account_b)
│   ├── variables.tf
│   ├── account_a.tf              # group1/2, engine/ci/alice/bob, roleA/roleB
│   ├── account_b.tf              # roleC, arrise-artifacts-bucket
│   ├── NOTES.md                  # Answers to both design questions
│   └── env/
│       └── sandbox/
│           ├── backend.tfvars
│           └── variables.tfvars
│
├── task4-least-privilege-policy/
│   ├── versions.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf                   # Custom policy attached to ci (ECR push, ECS deploy, S3 read)
│   ├── NOTES.md                  # What was included, what was left out and why
│   └── env/
│       └── sandbox/
│           ├── backend.tfvars
│           └── variables.tfvars
│
├── task5-bug-fix/
│   ├── versions.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── fixed_roleC.tf            # Fixed roleC trust and bucket-scoped S3 policy
│   ├── NOTES.md                  # Root cause of both bugs
│   └── env/
│       └── sandbox/
│           ├── backend.tfvars
│           └── variables.tfvars
│
├── DEVOPS ASSSIGNEMNT.docx
└── README.md
```

---

## How to Run Each Task

Run commands from the relevant task directory. Tasks 1, 3, 4, and 5 use this workflow:

```bash
# 1. Initialise – injects S3 backend config from the environment file
terraform init -backend-config=env/sandbox/backend.tfvars

# 2. Plan – loads environment-specific variable values
terraform plan -var-file=env/sandbox/variables.tfvars

# 3. Apply
terraform apply -var-file=env/sandbox/variables.tfvars
```

Task 2 has no managed AWS resources of its own; it demonstrates the S3 backend and lock
configuration. Initialize it with `terraform init -backend-config=env/sandbox/backend.tfvars`.
Apply Task 3 before Task 4 because the policy attaches to the `ci` user created in Task 3.
Task 5 is a standalone corrected example of the same `roleC` created in Task 3; do not
apply both as separate states to the same accounts.

---

## Remote State Layout in S3

Every task writes its state to a unique key in the **`arrise-devops-tfstate`** bucket:

| Task | State Key |
|------|-----------|
| Task 1 | `task1-ec2/sandbox/terraform.tfstate` |
| Task 2 | `task2-remote-state/sandbox/terraform.tfstate` |
| Task 3 | `task3-iam/sandbox/terraform.tfstate` |
| Task 4 | `task4-iam-policy/sandbox/terraform.tfstate` |
| Task 5 | `task5-bug-fix/sandbox/terraform.tfstate` |

All five backends use S3-native state locking with `use_lockfile = true`. Terraform creates
a `.tflock` object beside each state while a state-writing operation is in progress. The
original assignment asks for DynamoDB locking; DynamoDB locking is deprecated, not
unsupported. This submission uses S3-native locking instead and does not provision or
require a DynamoDB lock table. Terraform 1.10 or later is required.

With separate local state files, two people can plan from different snapshots, make
conflicting changes, and leave state files that disagree with AWS. Task 2 uses the shared
S3 bucket already used by Task 1, with its own state key. The S3 lockfile prevents
concurrent Terraform runs using that backend state from writing at the same time.

The state bucket must exist before `terraform init`; enable S3 versioning to recover
previous state versions. Task 3 requires two configured AWS CLI profiles, one for each
account. The account IDs in sandbox variable files are assignment placeholders and must
match the authenticated accounts before applying.

---

## Adding a New Environment (e.g., production)

```bash
mkdir -p task1-ec2-provisioning/env/production
cp task1-ec2-provisioning/env/sandbox/backend.tfvars   task1-ec2-provisioning/env/production/backend.tfvars
cp task1-ec2-provisioning/env/sandbox/variables.tfvars task1-ec2-provisioning/env/production/variables.tfvars
# Edit the new files with production-specific values, then:
terraform init   -backend-config=env/production/backend.tfvars
terraform apply  -var-file=env/production/variables.tfvars
```

---

## Resource Naming Convention

| Resource | Name |
|----------|------|
| Terraform state bucket | `arrise-devops-tfstate` |
| State locking | S3 lockfile (`use_lockfile = true`) |
| EC2 instances | `arrise-<role>` (e.g. `arrise-db-server`) |
| IAM groups | `group1`, `group2` |
| IAM users | `engine`, `ci`, `alice`, `bob` |
| IAM roles | `roleA`, `roleB`, `roleC` |
| IAM policy | `arrise-ci-least-privilege-policy` |
| ECR repository | `arrise-app` |
| ECS cluster / service | `arrise-cluster` / `arrise-service` |
| S3 artifacts bucket | `arrise-artifacts-bucket` |
| S3 build artifacts | `arrise-build-artifacts` |

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | ≥ 1.10.0 (S3-native lockfiles are used by every task backend) |
| AWS CLI | ≥ 2.x |
| AWS Provider | ~> 5.0 |
