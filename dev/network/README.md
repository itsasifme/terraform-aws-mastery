# dev / network

The VPC for dev, built with the community [VPC module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws) from the Terraform Registry (pinned to `~> 6.0`).

## What it creates

| Resource | Value |
|---|---|
| VPC | `10.0.0.0/16` |
| Public subnets | `10.0.1.0/24` (1a), `10.0.2.0/24` (1b), `10.0.3.0/24` (1c) |
| Internet gateway | one, attached to the VPC |
| Route table | `0.0.0.0/0` → internet gateway, linked to all three subnets |

Servers in these subnets get a public IP automatically. There's no NAT gateway, because there are no private subnets and NAT costs money by the hour.

## Steps

**1. Init** (first time, or after cloning)

```bash
cd dev/network
terraform init -backend-config=../../backend.hcl
```

This downloads the AWS provider and the VPC module, and connects to the state bucket.

**2. Plan**

```bash
terraform plan
```

Every resource shows up as `module.vpc.<type>.<name>`, for example `module.vpc.aws_vpc.this[0]`. That prefix means it was created inside the module.

**3. Apply**

```bash
terraform apply
```

**4. Destroy** (only after [`../app`](../app) is destroyed)

```bash
terraform destroy
```

## Outputs

These are read by [`../app`](../app) through `terraform_remote_state`.

| Name | Description |
|---|---|
| `vpc_id` | ID of the VPC |
| `public_subnet_ids` | list of the three subnet IDs |

Remove an output here and `app` breaks: remote state can only see outputs, nothing else.
