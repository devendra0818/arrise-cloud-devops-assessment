output "instance_ids" {
  description = "Map of EC2 instance names to instance IDs"
  value = merge(
    { for name, instance in aws_instance.normal : "arrise-${name}" => instance.id },
    { for name, instance in aws_instance.protected : "arrise-${name}" => instance.id }
  )
}

output "instance_private_ips" {
  description = "Map of EC2 instance names to private IP addresses"
  value = merge(
    { for name, instance in aws_instance.normal : "arrise-${name}" => instance.private_ip },
    { for name, instance in aws_instance.protected : "arrise-${name}" => instance.private_ip }
  )
}
