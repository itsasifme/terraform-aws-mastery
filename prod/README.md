# prod

Production environment. The real thing. SSH is closed, and nothing reaches here without passing dev and stag first.

| Setting | Value |
|---|---|
| VPC | `10.1.0.0/16` |
| Subnets | `10.1.1.0/24`, `10.1.2.0/24`, `10.1.3.0/24` (ap-south-1a, b, c) |
| Server | `t3.micro` with nginx |
| SSH | off |

## Folders

| Folder | What it does | State key |
|---|---|---|
| [`network`](network) | VPC, subnets, internet gateway, routing | `prod/network/terraform.tfstate` |
| [`app`](app) | security group + web server | `prod/app/terraform.tfstate` |

## Order

`app` reads its VPC and subnet from the `network` state, so the order matters.

**Bring it up**

1. [`network`](network): `terraform apply`
2. [`app`](app): `terraform apply`

**Tear it down**

1. [`app`](app): `terraform destroy`
2. [`network`](network): `terraform destroy`

AWS won't delete a VPC while a server is still inside it, which is why `app` goes first.

## Before you start

- The state bucket exists ([`bootstrap`](../bootstrap))
- `backend.hcl` is in the repo root
