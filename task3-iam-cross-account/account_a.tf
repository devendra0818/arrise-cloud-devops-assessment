########################################################################
# ACCOUNT A (var.account_a_id) – IAM Users, Groups, and Roles
########################################################################

locals {
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

# ── IAM Users ─────────────────────────────────────────────────────────────────

# group1 members – CLI/programmatic-only (no console login)
resource "aws_iam_user" "arrise_engine" {
  provider = aws.account_a
  name     = "arrise-engine"
  path     = "/"
  tags     = merge(local.common_tags, { Access = "programmatic-only", Group = "arrise-group1" })
}

resource "aws_iam_user" "arrise_ci" {
  provider = aws.account_a
  name     = "arrise-ci"
  path     = "/"
  tags     = merge(local.common_tags, { Access = "programmatic-only", Group = "arrise-group1" })
}

# group2 members – full console + CLI access
resource "aws_iam_user" "arrise_alice" {
  provider = aws.account_a
  name     = "arrise-alice"
  path     = "/"
  tags     = merge(local.common_tags, { Access = "console-and-cli", Group = "arrise-group2" })
}

resource "aws_iam_user" "arrise_bob" {
  provider = aws.account_a
  name     = "arrise-bob"
  path     = "/"
  tags     = merge(local.common_tags, { Access = "console-and-cli", Group = "arrise-group2" })
}

# ── arrise-group1: CLI / programmatic-only ────────────────────────────────────
resource "aws_iam_group" "arrise_group1" {
  provider = aws.account_a
  name     = "arrise-group1"
}

resource "aws_iam_group_membership" "arrise_group1_members" {
  provider = aws.account_a
  name     = "arrise-group1-membership"
  group    = aws_iam_group.arrise_group1.name
  users    = [aws_iam_user.arrise_engine.name, aws_iam_user.arrise_ci.name]
}

# Deny console (password) login for group1 – only access keys should be issued.
resource "aws_iam_group_policy" "arrise_group1_deny_console" {
  provider = aws.account_a
  name     = "arrise-deny-console-access"
  group    = aws_iam_group.arrise_group1.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyConsoleLogin"
      Effect = "Deny"
      Action = [
        "iam:CreateLoginProfile",
        "iam:UpdateLoginProfile",
        "iam:GetLoginProfile"
      ]
      Resource = "*"
    }]
  })
}

# ── arrise-group2: Full console + CLI ─────────────────────────────────────────
resource "aws_iam_group" "arrise_group2" {
  provider = aws.account_a
  name     = "arrise-group2"
}

resource "aws_iam_group_membership" "arrise_group2_members" {
  provider = aws.account_a
  name     = "arrise-group2-membership"
  group    = aws_iam_group.arrise_group2.name
  users    = [aws_iam_user.arrise_alice.name, aws_iam_user.arrise_bob.name]
}

resource "aws_iam_group_policy_attachment" "arrise_group2_power_user" {
  provider   = aws.account_a
  group      = aws_iam_group.arrise_group2.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# ── arrise-roleA: Admin to all services EXCEPT IAM ───────────────────────────
data "aws_iam_policy_document" "arrise_roleA_trust" {
  provider = aws.account_a

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:root"]
    }
  }
}

resource "aws_iam_role" "arrise_roleA" {
  provider           = aws.account_a
  name               = "arrise-roleA"
  assume_role_policy = data.aws_iam_policy_document.arrise_roleA_trust.json
  tags               = merge(local.common_tags, { Description = "Admin to all AWS services except IAM" })
}

resource "aws_iam_role_policy" "arrise_roleA_admin_except_iam" {
  provider = aws.account_a
  name     = "arrise-admin-except-iam"
  role     = aws_iam_role.arrise_roleA.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowAllExceptIAM"
      Effect    = "Allow"
      NotAction = ["iam:*"]
      Resource  = "*"
    }]
  })
}

# ── arrise-roleB: Can ONLY assume arrise-roleC in Account B ──────────────────
data "aws_iam_policy_document" "arrise_roleB_trust" {
  provider = aws.account_a

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:root"]
    }
  }
}

resource "aws_iam_role" "arrise_roleB" {
  provider           = aws.account_a
  name               = "arrise-roleB"
  assume_role_policy = data.aws_iam_policy_document.arrise_roleB_trust.json
  tags               = merge(local.common_tags, { Description = "Cross-account role – can only assume arrise-roleC in Account B" })
}

resource "aws_iam_role_policy" "arrise_roleB_assume_roleC" {
  provider = aws.account_a
  name     = "arrise-assume-roleC-in-account-b"
  role     = aws_iam_role.arrise_roleB.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AllowAssumeRoleC"
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = "arn:aws:iam::${var.account_b_id}:role/arrise-roleC"
    }]
  })
}
