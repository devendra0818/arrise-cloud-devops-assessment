# Output: instance name → instance ID (both normal and protected groups)
output "instance_ids" {
  description = "Map of instance name to instance ID"
  value = merge(
    { for name, inst in aws_instance.normal : "arrise-${name}" => inst.id },
    { for name, inst in aws_instance.protected : "arrise-${name}" => inst.id }
  )
}

# Output: instance name → private IP (both normal and protected groups)
output "instance_private_ips" {
  description = "Map of instance name to private IP address"
  value = merge(
    { for name, inst in aws_instance.normal : "arrise-${name}" => inst.private_ip },
    { for name, inst in aws_instance.protected : "arrise-${name}" => inst.private_ip }
  )
}
