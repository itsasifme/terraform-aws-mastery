# prod / app

The web server for prod. It calls the shared [`web-server`](../../modules/web-server) module and places it in the VPC from [`../network`](../network).

## What it creates

| Resource | Notes |
|---|---|
| Security group | HTTP (80) from anywhere, all outbound |
| SSH rule | no |
| EC2 instance | `t3.micro`, Amazon Linux 2023, nginx, in the first subnet (ap-south-1a) |

## How it finds the network

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "prod/network/terraform.tfstate"
    region = "ap-south-1"
  }
}
```

It reads `vpc_id` and `public_subnet_ids` from the network state. Nothing is hardcoded, but [`../network`](../network) must be applied first.

## Steps

**1. Fill in the variables** (first time only)

```bash
cd prod/app
cp terraform.tfvars.example terraform.tfvars
```

```hcl
state_bucket = "terraform-aws-mastery-tfstate-<account_id>"
```

`terraform.tfvars` is ignored by Git.

**2. Init**

```bash
terraform init -backend-config=../../backend.hcl
```

**3. Plan**

```bash
terraform plan     # 4 to add
```

Resources show up as `module.web.<type>.<name>`.

**4. Apply**

```bash
terraform apply
```

Wait a minute for nginx to install, then open the `website_url` output in a browser:

```
Hello from a Terraform module!
Server: terraform-aws-mastery-prod-web
```

**5. Destroy** (before [`../network`](../network))

```bash
terraform destroy
```

## Inputs

| Name | Required | Notes |
|---|---|---|
| `state_bucket` | yes | used to read the network state |
| `ssh_cidr` | no | your IP as `x.x.x.x/32`, or leave it out to keep SSH closed |

## Outputs

| Name | Description |
|---|---|
| `website_url` | `http://<public ip>` |

## SSH

No `ssh_cidr` is set, so the SSH rule isn't created at all. If you ever need a shell on the server, the usual way is SSM Session Manager instead of opening port 22. That needs an IAM role on the instance, which this module doesn't add yet.
