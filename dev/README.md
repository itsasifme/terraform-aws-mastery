# dev

Development environment. Where changes are tried first. This is the only environment I actually apply while learning.

| Setting | Value |
|---|---|
| VPC | `10.0.0.0/16` |
| Subnets | `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24` (ap-south-1a, b, c) |
| Server | `t3.micro` with nginx |
| SSH | open to one IP (`ssh_cidr`) |

## Folders

| Folder | What it does | State key |
|---|---|---|
| [`network`](network) | VPC, subnets, internet gateway, routing | `dev/network/terraform.tfstate` |
| [`app`](app) | security group + web server | `dev/app/terraform.tfstate` |

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
