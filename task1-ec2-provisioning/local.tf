locals {
  # Terraform lifecycle settings must be literal values. Split the map so only
  # the selected database instance gets prevent_destroy = true in the module.
  protected_instances = {
    for name, instance in var.instances : name => instance
    if instance.prevent_destroy
  }

  normal_instances = {
    for name, instance in var.instances : name => instance
    if !instance.prevent_destroy
  }

  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}
