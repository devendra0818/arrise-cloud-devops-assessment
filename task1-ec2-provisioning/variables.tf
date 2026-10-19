# ---------------------------------------------------------------------------
# variables.tf – declarations only; NO defaults.
# All values are supplied via env/sandbox/variables.tfvars (or another env).
# ---------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "environment" {
  description = "Deployment environment (sandbox | staging | production)"
  type        = string
}

variable "owner" {
  description = "Team or individual responsible for these resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for all EC2 instances"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where instances will be launched"
  type        = string
}

# Single variable map that drives all EC2 instances through the reusable module.
variable "instances" {
  description = "Map of EC2 instance configurations"
  type = map(object({
    instance_type   = string
    volume_type     = string
    volume_size     = number
    key_name        = string
    prevent_destroy = bool
  }))
}
