# Arrise Cloud DevOps Assessment

> **Terraform state bucket:** `arrise-devops-tfstate`
> **All resource names:** prefixed with `arrise-`
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
│   ├── account_a.tf              # arrise-group1/2, arrise-engine/ci/alice/bob, arrise-roleA/roleB
│   ├── account_b.tf              # arrise-roleC, arrise-artifacts-bucket
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
│   ├── main.tf                   # arrise-ci-least-privilege-policy (ECR push, ECS deploy, S3 read)
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
│   ├── fixed_roleC.tf            # Broken original (commented) + fixed arrise-roleC
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

All tasks follow the **same three-command workflow**:

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

Task 2 uses S3 state locking with `use_lockfile = true`. Terraform creates a `.tflock`
object beside the state while a state-writing operation is in progress. HashiCorp has
deprecated DynamoDB-based S3 locking in favor of S3 lockfiles; Task 2 does not provision a
DynamoDB lock table.

With separate local state files, two people can plan from different snapshots, make
conflicting changes, and leave state files that disagree with AWS. Task 2 uses the shared
S3 bucket already used by Task 1, with its own state key. The S3 lockfile prevents
concurrent Terraform runs using that backend state from writing at the same time.

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
| DynamoDB lock table (Tasks 3–5) | `arrise-terraform-state-lock` |
| EC2 instances | `arrise-<role>` (e.g. `arrise-db-server`) |
| IAM groups | `arrise-group1`, `arrise-group2` |
| IAM users | `arrise-engine`, `arrise-ci`, `arrise-alice`, `arrise-bob` |
| IAM roles | `arrise-roleA`, `arrise-roleB`, `arrise-roleC` |
| IAM policy | `arrise-ci-least-privilege-policy` |
| ECR repository | `arrise-app` |
| ECS cluster / service | `arrise-cluster` / `arrise-service` |
| S3 artifacts bucket | `arrise-artifacts-bucket` |
| S3 build artifacts | `arrise-build-artifacts` |

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | ≥ 1.10.0 for Task 2 S3 lockfiles; ≥ 1.3.0 for other tasks |
| AWS CLI | ≥ 2.x |
| AWS Provider | ~> 5.0 |
