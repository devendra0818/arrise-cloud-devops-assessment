# Task 3 Multi-Account IAM

## 1. Would I use IAM user access keys for `engine` and `ci` in production?

No. For `ci`, I would use short-lived credentials from an IAM role through OIDC
federation. For `engine`, I would attach an instance profile or workload role. For
employees, I would use IAM Identity Center. These options avoid long-lived access keys.

This configuration creates the requested IAM users and groups, but does not create
passwords or access keys. Issue credentials through the appropriate identity workflow.

## 2. Why trust roleB's ARN instead of Account A's root in roleC?

Trusting Account A's root lets any principal in Account A that also has permission to
assume `roleC` use it. Trusting the specific `arrise-roleB` ARN limits the trust policy
to that role. `roleB` also has an identity policy that permits it to assume only
`arrise-roleC`, so the cross-account access is limited at both ends.
