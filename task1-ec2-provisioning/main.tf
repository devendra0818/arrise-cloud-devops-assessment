locals {
  # Separate instances into two groups because lifecycle.prevent_destroy
  # cannot be set dynamically in Terraform — it must be a literal value.
  # Both groups are driven by the same single var.instances map.
  protected_instances = {
    for name, cfg in var.instances : name => cfg if cfg.prevent_destroy == true
  }
  normal_instances = {
    for name, cfg in var.instances : name => cfg if cfg.prevent_destroy == false
  }

  # Common tags applied to every resource
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

# ── Normal instances (prevent_destroy = false) ──────────────────────────────
resource "aws_instance" "normal" {
  for_each = local.normal_instances

  ami           = var.ami_id
  instance_type = each.value.instance_type
  subnet_id     = var.subnet_id
  key_name      = each.value.key_name

  root_block_device {
    volume_type = each.value.volume_type
    volume_size = each.value.volume_size

    # io1/io2 require explicit IOPS
    iops = contains(["io1", "io2"], each.value.volume_type) ? 3000 : null

    tags = merge(local.common_tags, {
      Name = "arrise-${each.key}-root-volume"
    })
  }

  tags = merge(local.common_tags, {
    Name = "arrise-${each.key}"
  })

  lifecycle {
    prevent_destroy = false
  }
}

# ── Protected instances (prevent_destroy = true) ──────────────────────────────
# "arrise-db-server" is the chosen protected instance — see NOTES.md for rationale.
resource "aws_instance" "protected" {
  for_each = local.protected_instances

  ami           = var.ami_id
  instance_type = each.value.instance_type
  subnet_id     = var.subnet_id
  key_name      = each.value.key_name

  root_block_device {
    volume_type = each.value.volume_type
    volume_size = each.value.volume_size
    iops        = contains(["io1", "io2"], each.value.volume_type) ? 3000 : null

    tags = merge(local.common_tags, {
      Name = "arrise-${each.key}-root-volume"
    })
  }

  tags = merge(local.common_tags, {
    Name = "arrise-${each.key}"
  })

  lifecycle {
    prevent_destroy = true
  }
}
