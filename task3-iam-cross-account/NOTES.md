# NOTES.md – Task 3: Multi-Account IAM & Cross-Account Access

---

## Q1: Would you give `engine` and `ci` IAM users with access keys in a real production setup?

**No. I would not use long-lived IAM access keys for `engine` and `ci` in production.**

Here is what I would do instead:

### For `ci` (CI/CD pipeline user)
- **Preferred**: Use an **IAM role assumed via OIDC federation** from the CI platform
  (GitHub Actions, GitLab CI, CircleCI, etc.). The CI platform issues a short-lived JWT token
  that the pipeline exchanges for temporary AWS credentials (via `sts:AssumeRoleWithWebIdentity`).
  - **No static access keys** are ever stored in the CI environment or secret manager.
  - Credentials expire automatically (typically in 1 hour).
  - If credentials are accidentally leaked (e.g., in a log), they are already expired.

### For `engine` (automated application/service)
- **Preferred**: Attach an **IAM instance profile** (if running on EC2) or an **ECS Task Role**
  (if running in containers) so the application receives temporary credentials automatically
  via the instance metadata service (IMDS). No keys are passed around at all.
- If the workload runs outside AWS (e.g., on-premises), use **AWS IAM Roles Anywhere** with
  X.509 certificates to issue short-lived credentials without static keys.

### Why static access keys are dangerous
| Risk                  | Details                                                    |
|-----------------------|------------------------------------------------------------|
| Long-lived            | Keys never rotate unless manually rotated (often forgotten) |
| Accidental exposure   | Committed to git, leaked in logs, found in S3 buckets      |
| Broad blast radius    | Once compromised, attacker has full programmatic access     |
| No MFA enforcement    | API calls can't be protected by MFA (unlike console logins)|

---

## Q2: Why does it matter whether roleC's trust policy trusts Account A root vs. roleB's specific ARN?

### Trusting the Account A root (`arn:aws:iam::000000000000:root`)

When you trust the **account root**, you are saying:
> "Any IAM principal in Account A that has been granted `sts:AssumeRole` permission can assume roleC."

This means:
- `roleB` can assume roleC ✅
- `roleA` can also assume roleC (if it has an sts:AssumeRole policy) ✅ (unintended!)
- Any admin user in Account A can assume roleC ✅ (unintended!)
- Any new role or user ever created in Account A with the right policy can assume roleC ✅ (unintended!)

The trust policy is a **necessary but not sufficient** condition – IAM evaluates BOTH the
resource-based trust policy (on the role) AND the identity-based permission policy (on the caller).
But trusting the root means Account A admins can grant ANY principal the ability to assume roleC.

### Trusting roleB's specific ARN (`arn:aws:iam::000000000000:role/roleB`)

When you trust the **specific role ARN**, you are saying:
> "Only the identity whose ARN is exactly `arn:aws:iam::000000000000:role/roleB` can assume roleC."

- No Account A admin can grant a different user or role the ability to assume roleC.
- Even if someone in Account A adds `sts:AssumeRole` for roleC to another role, Account B's
  trust policy will **reject the request**.
- This enforces **least-privilege** at the cross-account boundary.

### Conclusion
Trusting the specific ARN of `roleB` is the correct approach. It makes the cross-account
boundary explicit and prevents privilege escalation via Account A. Trusting the root would
make roleC accessible to far more principals than intended.
