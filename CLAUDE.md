# Terraform on AWS: Learning Session Handoff

> Claude Code reads this file automatically and continues teaching from where we stopped.

## Who I am and how to teach me

- I'm learning **Terraform for AWS only**, from A to Z, aiming for about 1 hour in total.
- Teach **step by step, one module at a time**. Explain the concept, show working code, then give me a small hands-on task or quiz before moving on.
- I ask a lot of "why" questions about real-world practice (how companies do it). Answer them with analogies and concrete examples, then return to the plan.
- My team at work already uses: a **Git repo with CI that runs `terraform plan` on PRs and CD that runs `apply` on merge**, plus an **S3 bucket for remote state** that my lead created.
- Use **AWS Free Tier** resources where possible, and always finish hands-on work with `terraform destroy` so I'm not billed.
- Since we're in Claude Code: **create the files in this folder and let me run the commands myself** (`init`, `plan`, `apply`, `destroy`), unless I ask you to run them. Explain each plan output with me.

## Progress so far

| Module | Status |
|---|---|
| 1. Foundations | ✅ Done (quiz score 2.5/3) |
| 2. Setup | ✅ Done (Terraform 1.17.2, AWS CLI 2.34.0, IAM user verified on 2026-11-19) |
| 3. Core workflow and HCL basics | ✅ Done (created S3 bucket in ap-south-1; skipped the tag-change step, saw `~` explained only) |
| 4. Variables, outputs, locals, data sources | ✅ Done (EC2 in ec2/ applied and destroyed; quiz not answered yet) |
| 5. A real AWS network | 📖 **In progress** (code in web-app/, validated, not applied yet) |
| 6–8 | Not started |

**Folder layout (since 2026-11-20):** one folder per AWS service, each with its own providers, variables, tfvars and state. `s3/` holds the Module 3 bucket (state moved there, so plan should show no changes). `ec2/` holds the Module 4 instance. Run commands inside the service folder. New services get a new folder.

### Concepts I've already learned (don't re-teach, but quick refreshers are fine)

**Module 1: Foundations**
- Infrastructure as Code: repeatable, version-controlled, reviewable, fast.
- **Declarative vs imperative:** describe the end state (`count = 2`); Terraform works out the steps.
- **Terraform compares three things:** code (what I want), state (what Terraform remembers it built), real AWS (what exists). Note: I first confused these with add/change/destroy. Those are the *actions* in a plan, not the things compared.
- Core workflow: `init` → `plan` → `apply` → `destroy`. Always read the plan before applying.
- Changing `count = 3` to `count = 2` destroys one instance (`aws_instance.web[2]`).
- Terraform vs Console vs CloudFormation. OpenTofu is the open-source fork created after the 2023 BSL license change.

**Providers (my side questions)**
- **Terraform Core** plans; **providers** are separate plugins that call cloud APIs. The AWS provider uses the AWS SDK for Go.
- `hashicorp/aws` is an **official-tier** provider maintained by a small HashiCorp team (HashiCorp is now an IBM company), with contributions from AWS and the community. It's released very often, roughly weekly.
- Registry tiers: Official / Partner / Community. Name format is `namespace/provider`.
- If AWS launches a feature the provider doesn't support yet: upgrade the provider when it lands, use the **`awscc`** provider (auto-generated from CloudFormation schemas), use `terraform_data` + `local-exec` with the AWS CLI as a stopgap, or set it manually and use `lifecycle { ignore_changes }`.
- Pin versions with `version = "~> 6.0"`.

**State file (my side questions)**
- State maps code to real resources (e.g. `aws_instance.web` = `i-0a1b2c3d`). Analogy: a warehouse inventory notebook.
- Terraform Core writes state after `apply` and `destroy`, using values AWS returns (IDs, IPs, ARNs). `plan` refreshes but doesn't save. A backup copy is kept as `terraform.tfstate.backup`.
- Losing state means Terraform tries to create duplicates.
- **Never commit state to Git:** secrets in plain text, no locking, merge conflicts.
- **Commit:** `*.tf` and `.terraform.lock.hcl`. **Ignore:** `*.tfstate*`, `.terraform/`, secret `*.tfvars`.
- Remote state in **S3** with `encrypt = true` and `use_lockfile = true` (newer S3-native locking; older setups use DynamoDB). Turn on S3 versioning for recovery.
- **Why my team needs S3 state even with Git and CI/CD:** CI runners are temporary, so local state would vanish after each job. The PR plan and the merge apply run on different machines and need the same shared state. Locking stops parallel applies. Secrets stay out of Git. Versioning allows recovery. Engineers can plan locally against the same state. `terraform_remote_state` lets projects read each other's outputs.

**`destroy` vs `apply` (my side questions)**
- To remove a few resources, delete them from the code and `apply`. `destroy` removes **everything** the configuration manages (like applying empty code).
- Real uses: temporary PR or test environments, nightly teardown of dev/staging, decommissioning, labs.
- For cost-saving on schedules (like a batch server), companies usually **stop instances, use scheduled Auto Scaling, or use AWS Batch, Lambda or Fargate**. Terraform builds those once; AWS handles the daily on/off.

**Module 2: Setup**
- Install Terraform and the AWS CLI. Create an IAM user (not root), run `aws configure`, and test with `aws sts get-caller-identity`.
- Credential order: environment variables → `~/.aws/credentials` → IAM role. Never hard-code keys in `.tf` files. CI should use an IAM role with OIDC.
- Create a zero-spend AWS Budget.
- File layout: `main.tf`, `providers.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`, `.gitignore`. Terraform reads all `.tf` files in a folder.

## Plan to continue

### Module 3: Core workflow and HCL basics (10 min)
- HCL syntax: blocks, arguments, expressions, references (`aws_s3_bucket.x.id`)
- `terraform {}` with `required_providers`, and a `provider "aws"` block with region and `default_tags`
- First resource: **S3 bucket** (globally unique name, e.g. using `random_id`)
- Run `init` (look at `.terraform/` and `.terraform.lock.hcl`) → `plan` (read the `+ ~ -` symbols) → `apply` → inspect `terraform.tfstate` → change a tag and see an in-place update → `destroy`
- `terraform fmt` and `terraform validate`
- 🛠 Hands-on: create, modify and destroy an S3 bucket

### Module 4: Variables, outputs, locals, data sources (8 min)
- `variable` (types, defaults, `validation`, `sensitive`), `terraform.tfvars`, `-var`, `TF_VAR_` environment variables
- `output`, `locals`
- `data "aws_ami"` to find the latest Amazon Linux AMI, and `data "aws_availability_zones"`
- 🛠 Hands-on: launch a `t3.micro` EC2 instance using variables and print its public IP

### Module 5: A real AWS network (10 min)
- VPC, public subnet, internet gateway, route table and association, security group (ports 22/80)
- Implicit dependencies (references) vs `depends_on`
- `count` vs `for_each` (and why `for_each` is safer when you remove items)
- `user_data` to install nginx
- 🛠 Hands-on: VPC + public subnet + EC2 web server reachable in a browser, then `destroy`

### Module 6: State management (7 min)
- Bootstrap an S3 state bucket (versioning, encryption, block public access)
- `backend "s3"` with `use_lockfile = true`, `terraform init -migrate-state`
- `terraform state list/show/mv/rm`, `import` blocks, drift detection with `plan -refresh-only`
- Relate this to my team's existing S3 state bucket and CI/CD
- 🛠 Hands-on: move my local state to S3

### Module 7: Modules (7 min)
- Write a local module (`modules/web-server`) with inputs and outputs
- Use the Registry module `terraform-aws-modules/vpc/aws` with version pinning
- Environments: workspaces vs separate folders (dev/staging/prod), and `terraform_remote_state`
- 🛠 Hands-on: refactor Module 5 into a module
- 🛠 Restructure the repo like my company: `modules/` + `dev/` + `stag/` + `prod/` + `global/` (env first, split by component like network/app, not by AWS service). Replace the current `s3/` and `ec2/` learning folders. Also show `terraform providers lock` for mixed Windows/Mac/Linux teams.

### Module 8: Pro practices and wrap-up (8 min)
- `lifecycle` (`create_before_destroy`, `prevent_destroy`, `ignore_changes`), `moved` blocks
- Secrets: SSM Parameter Store / Secrets Manager, `sensitive = true`
- CI/CD: GitHub Actions with OIDC, plan on PR and apply on merge (matches my team), tflint, checkov or trivy
- Common mistakes and interview questions
- 🎯 Final mini-project: VPC + EC2 web server using a module, remote state, variables and outputs, then `destroy`
