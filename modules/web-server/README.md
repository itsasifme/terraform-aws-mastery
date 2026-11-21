# web-server

A small web server on EC2: one security group and one instance running nginx.
Used by `dev/app`, `stag/app` and `prod/app`.

## What it creates

| Resource | Notes |
|---|---|
| `aws_security_group` | HTTP (80) open to everyone, all outbound traffic allowed |
| `aws_vpc_security_group_ingress_rule.ssh` | only when `ssh_cidr` is set |
| `aws_instance` | latest Amazon Linux 2023, nginx installed by `user_data`, IMDSv2 required |

## Usage

```hcl
module "web" {
  source = "../../modules/web-server"

  name          = "terraform-aws-mastery-dev"
  vpc_id        = data.terraform_remote_state.network.outputs.vpc_id
  subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  instance_type = "t3.micro"
  ssh_cidr      = var.ssh_cidr # null = no SSH rule at all
}
```

## Inputs

| Name | Required | Default | Notes |
|---|---|---|---|
| `name` | yes | | prefix for every resource name |
| `vpc_id` | yes | | |
| `subnet_id` | yes | | must be a public subnet |
| `instance_type` | no | `t3.micro` | limited to `t3.micro` or `t2.micro` to keep the bill low |
| `ssh_cidr` | no | `null` | your IP as `x.x.x.x/32` |

## Outputs

| Name | Description |
|---|---|
| `instance_id` | EC2 instance ID |
| `public_ip` | public IP of the server |
| `security_group_id` | ID of the security group |

## Notes

- There's no `provider` block here. Region and credentials come from whoever calls the module.
- Changing `user_data` replaces the instance (`user_data_replace_on_change = true`), so the new script actually runs.
