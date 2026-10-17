# env/sandbox/variables.tfvars
# ─────────────────────────────────────────────────────────────
# Usage:
#   terraform plan  -var-file=env/sandbox/variables.tfvars
#   terraform apply -var-file=env/sandbox/variables.tfvars
# ─────────────────────────────────────────────────────────────

aws_region  = "us-east-1"
environment = "sandbox"
owner       = "arrise-devops-team"

# Replace with the actual AMI ID for your region (Amazon Linux 2023 in us-east-1)
ami_id    = "ami-0c55b159cbfafe1f0"
subnet_id = "subnet-xxxxxxxxxxxxxxxxx"

# Single map drives ALL 5 EC2 instances via for_each.
# Resource names will be prefixed with "arrise-" automatically in main.tf.
instances = {
  "app-server" = {
    instance_type   = "t3.micro"
    volume_type     = "gp3"
    volume_size     = 20
    key_name        = "arrise-app-server-key"
    prevent_destroy = false
  }
  "db-server" = {
    instance_type   = "t3.small"
    volume_type     = "io1" # Satisfies the io1/io2 requirement
    volume_size     = 50
    key_name        = "arrise-db-server-key"
    prevent_destroy = true # Protected – see NOTES.md
  }
  "cache-server" = {
    instance_type   = "t3.medium"
    volume_type     = "gp2"
    volume_size     = 30
    key_name        = "arrise-cache-server-key"
    prevent_destroy = false
  }
  "worker-server" = {
    instance_type   = "t3.large"
    volume_type     = "io2"
    volume_size     = 100
    key_name        = "arrise-worker-server-key"
    prevent_destroy = false
  }
  "bastion-host" = {
    instance_type   = "t2.micro"
    volume_type     = "standard"
    volume_size     = 10
    key_name        = "arrise-bastion-key"
    prevent_destroy = false
  }
}
