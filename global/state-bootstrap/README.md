# state-bootstrap

Creates the S3 bucket that stores the Terraform state of every other folder in this repo.
Run it once per AWS account, before anything else.

## What it creates

| Resource | Why |
|---|---|
| S3 bucket `<project>-tfstate-<account_id>` | the account ID makes the name unique, no random suffix needed |
| Versioning | every old version of a state file is kept, so a broken state can be rolled back |
| Encryption (AES256) | state can hold secrets in plain text |
| Public access block | the bucket can never be made public |

## Why this folder keeps its state locally

There's no `backend` block here on purpose. This folder creates the bucket, so its own state can't live in that bucket: the bucket doesn't exist yet when it runs. Its state stays in `terraform.tfstate` on disk.

That file is ignored by Git, so keep it safe. Without it, Terraform no longer knows it manages the bucket.

## Steps

**1. Check the AWS CLI works**

```bash
aws sts get-caller-identity
```

**2. Create the bucket**

```bash
cd global/state-bootstrap
terraform init
terraform plan     # 4 to add
terraform apply
```

**3. Write the backend config for the other folders**

```bash
terraform output -raw backend_hcl > ../../backend.hcl
```

This creates `backend.hcl` in the repo root:

```hcl
bucket = "terraform-aws-mastery-tfstate-<account_id>"
region = "ap-south-1"
```

Every environment folder reads it during `terraform init -backend-config=../../backend.hcl`.

## Inputs

| Name | Default | Notes |
|---|---|---|
| `aws_region` | `ap-south-1` | |
| `project_name` | `terraform-aws-mastery` | part of the bucket name |

## Outputs

| Name | Description |
|---|---|
| `state_bucket` | name of the bucket |
| `backend_hcl` | ready-to-use content for `backend.hcl` |

## Be careful

- Changing `project_name` changes the bucket name. S3 buckets can't be renamed, so Terraform will **destroy the bucket and create a new one**, along with every state file inside it.
- `force_destroy = true` is set so the lab can be cleaned up completely. In a real company this would be `false`, with `lifecycle { prevent_destroy = true }`.
- Only destroy this after every environment has been destroyed.
