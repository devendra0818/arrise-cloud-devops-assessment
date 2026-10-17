module "ec2_instances" {
  source = "./modules/ec2_instance"

  ami_id              = var.ami_id
  subnet_id           = var.subnet_id
  normal_instances    = local.normal_instances
  protected_instances = local.protected_instances
  common_tags         = local.common_tags
}

# Preserve existing state addresses while moving the EC2 resources into a module.
moved {
  from = aws_instance.normal
  to   = module.ec2_instances.aws_instance.normal
}

moved {
  from = aws_instance.protected
  to   = module.ec2_instances.aws_instance.protected
}
