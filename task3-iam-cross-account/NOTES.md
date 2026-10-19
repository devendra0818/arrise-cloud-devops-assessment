# Task 3 — Multi-Account IAM

The configuration creates the requested `group1`/`group2`, users, and `roleA`/
`roleB`/`roleC`. `group2` receives `AdministratorAccess` for full AWS console and
CLI permissions. User credentials are not generated or saved in Terraform state;
group membership and permissions do not themselves create console passwords or CLI
credentials. Configure authentication through the organization's identity process.
The two account providers use separate AWS CLI profiles (`arrise-account-a` and
`arrise-account-b`) and verify the configured account IDs. The S3 backend uses the
AWS credentials available during `terraform init` and must also be able to access
the state bucket.

## 1. Would I use IAM user access keys for `engine` and `ci` in production?

No. For `ci`, I would use short-lived credentials through OIDC federation. For a
human engineer, I would use IAM Identity Center. For an AWS workload, I would use
an instance profile or workload role. These options avoid long-lived access keys.

## 2. Why trust roleB's ARN instead of Account A's root in roleC?

Trusting Account A's root allows principals in Account A that are also authorized
to assume `roleC` to use it. Trusting the specific `roleB` ARN narrows the trust
to that role. `roleB`'s identity policy also allows it to assume only `roleC`.
