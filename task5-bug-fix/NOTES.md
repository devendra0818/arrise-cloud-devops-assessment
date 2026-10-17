# NOTES.md – Task 5: Find and Fix the Bug

## The two bugs and why each one broke the code

---

### Bug 1 – Wrong ARN type in the trust policy (`user/` instead of `role/`)

**Broken line:**
```hcl
identifiers = ["arn:aws:iam::000000000000:user/roleB"]
```

**Fixed line:**
```hcl
identifiers = ["arn:aws:iam::000000000000:role/roleB"]
```

#### Why it was failing

An AWS ARN encodes the **type** of IAM principal in its path:

| Principal type | ARN format                                   |
|----------------|----------------------------------------------|
| IAM User       | `arn:aws:iam::<account>:user/<username>`      |
| IAM Role       | `arn:aws:iam::<account>:role/<rolename>`      |

`roleB` is an **IAM Role**, not an IAM User. When `roleB` calls `sts:AssumeRole` on `roleC`,
AWS STS evaluates the trust policy in Account B. The caller's ARN will look like:
```
arn:aws:iam::000000000000:role/roleB
```

But the trust policy only allows:
```
arn:aws:iam::000000000000:user/roleB
```

These two ARNs are **completely different strings**. AWS does an exact ARN match in trust
policies, so the condition never evaluates to `true`. AWS STS returns:

```
An error occurred (AccessDenied) when calling the AssumeRole operation:
User: arn:aws:iam::000000000000:role/roleB is not authorized to perform:
sts:AssumeRole on resource: arn:aws:iam::111111111111:role/roleC
```

The fix is simple: change `:user/roleB` to `:role/roleB` so the ARN matches the actual
type of the principal that will be calling AssumeRole.

---

### Bug 2 – Overly broad S3 permissions (`Resource = "*"`)

**Broken line:**
```hcl
Resource = "*"
```

**Fixed lines:**
```hcl
Resource = [
  "arn:aws:s3:::arrise-artifacts-bucket",
  "arn:aws:s3:::arrise-artifacts-bucket/*"
]
```

#### Why it was failing (functionally, not as an API error)

`Resource = "*"` grants `s3:*` (all S3 actions) on **every bucket** in Account B — which
directly contradicts the assignment requirement:

> _"roleC: full access to a **single named S3 bucket**"_

With `Resource = "*"`, roleC could:
- List, read, write, and delete objects in **any** S3 bucket in Account B.
- Delete or modify bucket policies of **any** bucket.
- Create new buckets or replicate data anywhere.

This is a **least-privilege violation** and a potential data exfiltration risk: if `roleB`
(and therefore `roleC`) were ever compromised, the attacker would have unrestricted S3 access
across the entire account.

The fix scopes `Resource` to the two required ARNs for the specific bucket:
1. `arn:aws:s3:::arrise-artifacts-bucket` — grants bucket-level operations (`s3:ListBucket`, etc.)
2. `arn:aws:s3:::arrise-artifacts-bucket/*` — grants object-level operations (`s3:GetObject`, `s3:PutObject`, etc.)

Both ARNs are required because S3 bucket-level and object-level operations use different
resource namespaces in IAM evaluation.

---

## Summary of fixes

| # | Location           | Issue                                    | Fix                                              |
|---|--------------------|------------------------------------------|--------------------------------------------------|
| 1 | `roleC_trust` data | ARN path `:user/roleB` (wrong type)      | Changed to `:role/roleB`                         |
| 2 | `roleC_s3` policy  | `Resource = "*"` (all S3 buckets)        | Scoped to `arrise-artifacts-bucket` ARN pair     |
