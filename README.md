# terraform-aws-mastery

My notes and code from learning Terraform on AWS, step by step.
The repo is laid out the way many real teams do it: environment first, then component.

Region: `ap-south-1` (Mumbai). Everything here fits in the AWS Free Tier.

## Layout

```
modules/
  web-server/          reusable module: security group + EC2 with nginx
global/
  state-bootstrap/     S3 bucket that holds the state of every other folder
dev/
  network/             VPC and public subnets (Registry VPC module)
  app/                 web server, calls modules/web-server
prod/
  network/             same as dev, different IP range
  app/                 same module, SSH turned off
```

Each folder under `dev/` and `prod/` has its own state in S3:
`<env>/<component>/terraform.tfstate`, for example `dev/network/terraform.tfstate`.

`app` reads the VPC and subnet IDs from the `network` state using `terraform_remote_state`.
So `network` must be applied before `app`.

## First time setup

1. Create the state bucket (this folder keeps its own state locally):

   ```bash
   cd global/state-bootstrap
   terraform init
   terraform apply
   terraform output -raw backend_hcl > ../../backend.hcl
   ```

2. In `dev/app` (and `prod/app`), copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your bucket name.

## Run an environment

```bash
cd dev/network
terraform init -backend-config=../../backend.hcl
terraform apply

cd ../app
terraform init -backend-config=../../backend.hcl
terraform apply        # prints website_url
```

Open `website_url` in a browser. You should see "Hello from a Terraform module!".

## Clean up

Destroy in reverse order. The server lives inside the VPC, so it has to go first.

```bash
cd dev/app && terraform destroy
cd ../network && terraform destroy
```

## Not in Git

State files, `.terraform/`, `backend.hcl` and `*.tfvars` are ignored. Use the `.example` files as a starting point.

## What I covered

1. Foundations: infrastructure as code, how Terraform compares code, state and real AWS
2. Setup: Terraform, AWS CLI, IAM user
3. Core workflow: `init`, `plan`, `apply`, `destroy`, HCL basics
4. Variables, outputs, locals, data sources
5. A real network: VPC, subnet, internet gateway, route table, security group
6. State: S3 backend with locking, `state mv`, `import` and `removed` blocks, drift
7. Modules: local and Registry modules, `terraform_remote_state`, workspaces vs folders
8. Pro practices: lifecycle, secrets, CI/CD (coming next)
