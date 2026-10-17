variable "ami_id" {
  description = "AMI used by the EC2 instances"
  type        = string
}

variable "subnet_id" {
  description = "Subnet where the EC2 instances are launched"
  type        = string
}

variable "normal_instances" {
  description = "Instance configurations without deletion protection"
  type = map(object({
    instance_type   = string
    volume_type     = string
    volume_size     = number
    key_name        = string
    prevent_destroy = bool
  }))
}

variable "protected_instances" {
  description = "Instance configurations protected from Terraform destruction"
  type = map(object({
    instance_type   = string
    volume_type     = string
    volume_size     = number
    key_name        = string
    prevent_destroy = bool
  }))
}

variable "common_tags" {
  description = "Tags applied to each instance and root volume"
  type        = map(string)
}
