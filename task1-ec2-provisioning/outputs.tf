output "instance_ids" {
  description = "Map of EC2 instance names to instance IDs"
  value       = module.ec2_instances.instance_ids
}

output "instance_private_ips" {
  description = "Map of EC2 instance names to private IP addresses"
  value       = module.ec2_instances.instance_private_ips
}
