# NOTES.md – Task 1: Multi-Instance EC2 Provisioning

The root configuration passes the single `instances` map into the reusable
`modules/ec2_instance` module. The root `local.tf` prepares shared tags and separates
the protected database instance from the other instances because Terraform requires
`lifecycle.prevent_destroy` to be a literal value.

The sandbox environment supplies the AMI and subnet IDs in `env/sandbox/variables.tfvars`.
Keep both IDs in the same AWS region, and ensure the subnet belongs to the VPC intended
for this deployment.

## Which instance has `prevent_destroy = true` and why?

The **`db-server`** instance is protected with `lifecycle { prevent_destroy = true }`.

### Rationale
The database server holds persistent application data. Unlike stateless application,
cache, worker, or bastion hosts — which can be reprovisioned without data loss — the
database instance typically stores irreplaceable state. An accidental `terraform destroy`
or `-target` destroy command on this instance could cause permanent data loss, even if
EBS snapshots exist, because:

1. **RPO risk** – there is always a gap between the last snapshot and the moment of deletion.
2. **RDS vs EC2** – when running a self-managed DB on EC2, there is no automated multi-AZ
   failover or point-in-time recovery; `prevent_destroy` acts as a last line of defence.
3. **Production safety** – CI pipelines and automation scripts sometimes run broad
   `terraform destroy` commands; this guard prevents an accidental wipe of production data.

> **Note:** `prevent_destroy` only prevents Terraform from deleting the resource.
> The instance can still be terminated manually via the AWS console or CLI if truly needed.

## Volume Types Chosen

| Instance       | Volume Type | Reason                                          |
|----------------|-------------|--------------------------------------------------|
| app-server     | gp3         | General purpose, cost-effective for app workload |
| db-server      | io1         | High IOPS required for database I/O             |
| cache-server   | gp2         | Satisfactory performance for caching layer       |
| worker-server  | io2         | Durable, provisioned IOPS for worker data        |
| bastion-host   | standard    | Low-cost legacy magnetic root volume             |

The `io1` volume on `db-server` satisfies the assignment requirement that at least one
instance must use `io1` or `io2` storage. All five selected types are valid for EBS root
volumes; throughput-optimized `st1` and cold `sc1` volumes cannot be used as root volumes.
