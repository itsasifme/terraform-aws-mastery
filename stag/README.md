# stag

Staging environment. A copy of prod with its own IP range. Changes are tested here before they go to prod.

| Setting | Value |
|---|---|
| VPC | `10.2.0.0/16` |
| Subnets | `10.2.1.0/24`, `10.2.2.0/24`, `10.2.3.0/24` (ap-south-1a, b, c) |
| Server | `t3.micro` with nginx |
| SSH | off |

## Folders

| Folder | What it does | State key |
|---|---|---|
| [`network`](network) | VPC, subnets, internet gateway, routing | `stag/network/terraform.tfstate` |
| [`app`](app) | security group + web server | `stag/app/terraform.tfstate` |

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

- The state bucket exists ([`global/state-bootstrap`](../global/state-bootstrap))
- `backend.hcl` is in the repo root
