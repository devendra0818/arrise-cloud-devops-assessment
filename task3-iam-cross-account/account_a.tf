locals {
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }

  users = toset([
    "engine",
    "ci",
    "alice",
    "bob"
  ])

  group_members = {
    "group1" = ["engine", "ci"]
    "group2" = ["alice", "bob"]
  }
}
resource "aws_iam_user" "users" {
  provider = aws.account_a
  for_each = local.users

  name = each.value
  tags = local.common_tags
}

resource "aws_iam_group" "groups" {
  provider = aws.account_a
  for_each = local.group_members

  name = each.key
}

resource "aws_iam_group_membership" "members" {
  provider = aws.account_a
  for_each = local.group_members

  name  = "${each.key}-membership"
  group = aws_iam_group.groups[each.key].name
  users = [for user in each.value : aws_iam_user.users[user].name]
}

resource "aws_iam_group_policy_attachment" "group2_admin" {
  provider   = aws.account_a
  group      = aws_iam_group.groups["group2"].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "roleA" {
  provider = aws.account_a
  name     = "roleA"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = "arn:aws:iam::${var.account_a_id}:root" }
    }]
  })
  tags = merge(local.common_tags, { Name = "roleA" })
}

resource "aws_iam_role_policy" "roleA_admin_except_iam" {
  provider = aws.account_a
  name     = "arrise-admin-except-iam"
  role     = aws_iam_role.roleA.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      NotAction = ["iam:*"]
      Resource  = "*"
    }]
  })
}

resource "aws_iam_role" "roleB" {
  provider = aws.account_a
  name     = "roleB"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = "arn:aws:iam::${var.account_a_id}:root" }
    }]
  })
  tags = merge(local.common_tags, { Name = "roleB" })
}

resource "aws_iam_role_policy" "roleB_assume_roleC" {
  provider = aws.account_a
  name     = "arrise-assume-roleC-in-account-b"
  role     = aws_iam_role.roleB.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = "arn:aws:iam::${var.account_b_id}:role/roleC"
    }]
  })
}
