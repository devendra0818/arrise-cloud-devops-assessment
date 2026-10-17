# ── Provider aliases for each account ─────────────────────────────────────────
# In real usage set the profile or assume_role block per environment.
provider "aws" {
  alias  = "account_a"
  region = var.aws_region
  # profile = "arrise-account-a"  # uncomment and set for real deployment
}

provider "aws" {
  alias  = "account_b"
  region = var.aws_region
  # profile = "arrise-account-b"  # uncomment and set for real deployment
}
