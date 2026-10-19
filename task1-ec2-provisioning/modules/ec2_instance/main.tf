resource "aws_instance" "normal" {
  for_each = var.normal_instances

  ami           = var.ami_id
  instance_type = each.value.instance_type
  subnet_id     = var.subnet_id
  key_name      = each.value.key_name

  root_block_device {
    volume_type = each.value.volume_type
    volume_size = each.value.volume_size
    iops        = contains(["io1", "io2"], each.value.volume_type) ? 3000 : null

    tags = merge(var.common_tags, {
      Name = "arrise-${each.key}-root-volume"
    })
  }

  tags = merge(var.common_tags, {
    Name = "arrise-${each.key}"
  })
}

resource "aws_instance" "protected" {
  for_each = var.protected_instances

  ami           = var.ami_id
  instance_type = each.value.instance_type
  subnet_id     = var.subnet_id
  key_name      = each.value.key_name

  root_block_device {
    volume_type = each.value.volume_type
    volume_size = each.value.volume_size
    iops        = contains(["io1", "io2"], each.value.volume_type) ? 3000 : null

    tags = merge(var.common_tags, {
      Name = "arrise-${each.key}-root-volume"
    })
  }

  tags = merge(var.common_tags, {
    Name = "arrise-${each.key}"
  })

  lifecycle {
    prevent_destroy = true
  }
}
