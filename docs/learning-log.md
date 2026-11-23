# Learning log

What I've covered so far, and what comes next. Goal: the Terraform Associate exam.

## Progress

| # | Topic | Status |
|---|---|---|
| 1 | Foundations | ✅ Done |
| 2 | Setup: Terraform, AWS CLI, IAM user | ✅ Done |
| 3 | Core workflow and HCL basics | ✅ Done |
| 4 | Variables, outputs, locals, data sources | ✅ Done |
| 5 | A real AWS network | ✅ Done |
| 6 | State management | ✅ Done |
| 7 | Modules and repo layout | ✅ Done |
| 8 | Pro practices | 📖 In progress |
| 9 | Real-world patterns | ⏳ Planned |
| 10 | Team-scale CI/CD and governance | ⏳ Planned |
| 11 | Platform and leadership | ⏳ Planned |
| 12 | Exam prep | ⏳ Planned |

### Where I am now

Module 8, part 1 (`lifecycle`). The code is in place:

- `ignore_changes = [ami]` on the server
- `name_prefix` + `create_before_destroy` on the security group
- `prevent_destroy` on the state bucket

Hands-on still to do:

1. `terraform plan -destroy` in `bootstrap` and see the error
2. Apply dev, change the SG description, and look for `+/-` in the plan
3. Destroy dev (app first)

### Pending commands (after the 2026-11-23 layout change)

The code was changed but nothing was run yet. Do these in the next session, before the hands-on above.

1. `tfenv use <version>` (1.11 or newer). tfenv has no version selected right now.
2. `terraform fmt -check -recursive` and `terraform validate` in each changed folder.
3. `aws s3 ls | grep tfstate`: does the state bucket still exist?
   - **No bucket:** run `bootstrap` from the start (`init`, `apply`, then `terraform output -raw backend_hcl > ../backend.hcl`).
   - **Bucket exists, but no local state:** bring it back with `import` blocks in `bootstrap/imports.tf`. Keep the file with a comment (see the import rule in CLAUDE.md).
4. `terraform init` in `bootstrap/`. The folder moved, so its `.terraform/` folder is gone.
5. `terraform plan` in `bootstrap/`. Expect only `~` updates: the `Component` tag changed from `state-bootstrap` to `bootstrap`.

### Pending docs work

No code here, only docs. Do it step by step, one folder at a time.

1. Rewrite the folder READMEs in the same format as [`bootstrap/README.md`](../bootstrap/README.md) (done): contents, overview, requirements, what it creates, usage with `###` steps, inputs and outputs tables, cost, exam tips. Order:
   - `global/`
   - `modules/`, then `modules/web-server/`
   - `dev/`, `dev/network/`, `dev/app/`
   - `stag/` and `prod/` (copies of dev, so same shape)
2. First ADR in `docs/adr/0001-repo-layout.md`: the 2026-11-23 layout decisions (see Notes, Module 7).

### Next

⭐ = likely on the Terraform Associate exam.

#### Module 8: Pro practices

_Parts 2 and 3. Part 1 is above._

- **Part 2:** secrets with SSM Parameter Store, `sensitive = true` ⭐
- **Part 3:** CI/CD basics with GitHub Actions: plan on pull request, apply on merge, OIDC instead of access keys, tflint and trivy

#### Module 9: Real-world patterns

_Writing the code like a team does._

1. `dynamic` blocks, `optional()` in object types, `try()` ⭐ (`default_tags` is already used in every `providers.tf`)
2. Testing and checks: `terraform test`, `check` blocks, `precondition` / `postcondition` ⭐
3. Hands-on: make a resource by hand in the console, then bring it in with an `import` block ⭐
4. IAM in `global/iam/`: `aws_iam_policy_document`, JSON files with `file()` / `templatefile()`, least privilege. KMS for encryption
5. Sharing values between folders: `terraform_remote_state` vs data source lookup by name or tag ⭐
6. Module versioning: git tags (`?ref=v1.2.0`), then promote dev → stag → prod. Today a module change hits every env at once ⭐

#### Module 10: Team-scale CI/CD and governance

_How a team ships safely._

1. Same Terraform version for everyone: `.terraform-version` file
2. Reusable workflows (`workflow_call`), plan only the changed folders (path filter), plan as a PR comment, pre-commit hooks
3. Safe apply: apply the saved plan file (`plan -out`), manual approval with GitHub Environments, branch protection, `CODEOWNERS`. No local apply on stag or prod
4. Drift detection: a scheduled `plan` that alerts on changes made by hand
5. Policy as code: OPA / Conftest (Sentinel on HCP Terraform ⭐), for rules like "every resource needs tags"
6. Cost: Infracost in PRs, AWS Budgets alerts
7. Dependency updates: Renovate or Dependabot for providers and modules

#### Module 11: Platform and leadership

_What a Cloud Infra / DevOps lead owns._

1. Multi-account: AWS Organizations, SCPs, IAM Identity Center (SSO), provider `assume_role` for cross-account access
2. State security: bucket policy per env, KMS encryption, replication or backup of the state bucket
3. Account baseline in `global/`: CloudTrail, AWS Config, GuardDuty, log retention, tag policy (`Owner`, `CostCenter`)
4. Production network: private subnets, ALB + Auto Scaling Group across AZs, SSM Session Manager instead of SSH, VPC endpoints
5. `data/` component (RDS): backups, `prevent_destroy`, deletion protection
6. Team docs: ADRs (first one: the 2026-11-23 layout decisions), runbooks (stuck lock, lost state), break-glass access, onboarding
7. Tooling choice: GitHub Actions vs Atlantis vs HCP Terraform vs Spacelift

#### Module 12: Exam prep

- HCP Terraform: workspaces, runs, Sentinel, private registry ⭐
- Common mistakes and interview questions
- 30-question mock test

## Notes

### 1. Foundations

- Infrastructure as code: repeatable, reviewed in Git, fast.
- Declarative: you describe the end state, Terraform works out the steps.
- Terraform compares three things: the code (what I want), the state (what Terraform built), and real AWS (what exists).
- Add, change and destroy are the actions in a plan, not the things being compared.
- Changing `count = 3` to `count = 2` destroys `aws_instance.web[2]`.
- OpenTofu is the open-source fork made after the 2023 license change.

### Providers

- Terraform Core makes the plan. Providers are plugins that call the cloud APIs.
- `hashicorp/aws` is an official provider and is released about every week.
- Registry tiers: Official, Partner, Community. Name format: `namespace/name`.
- If AWS has a feature the provider doesn't support yet: wait for a new provider version, use the `awscc` provider, or use `terraform_data` with `local-exec` for a while.
- Pin versions with `~> 6.0`. Commit `.terraform.lock.hcl`.
- `terraform providers lock -platform=...` adds hashes for Windows, Mac and Linux in a mixed team.

### 2. Setup

- Use an IAM user, not root. `aws configure`, then check with `aws sts get-caller-identity`.
- Credential order: environment variables, then `~/.aws/credentials`, then an IAM role.
- Never put keys in `.tf` files. CI uses an IAM role with OIDC.
- Terraform reads every `.tf` file in a folder. File names are only for people.

### 3. Core workflow and HCL

- `init` → `plan` → `apply` → `destroy`. Always read the plan.
- Plan symbols: `+` create, `~` update in place, `-` destroy, `-/+` replace (destroy first), `+/-` replace (create first).
- HCL: blocks, arguments, expressions, references like `aws_s3_bucket.x.id`.
- The local name in `type.name` is only for Terraform. Renaming it means destroy and create, unless you use a `moved` block.
- `terraform fmt` formats, `terraform validate` checks the code without calling AWS.

### 4. Variables, outputs, locals, data sources

- `variable`: type, default, `validation`, `sensitive`.
- Ways to set a variable: `terraform.tfvars` (auto-loaded), `*.auto.tfvars`, `-var`, `-var-file`, `TF_VAR_name`. `-var` on the command line wins.
- `locals`: a name for a value built from other values. Variables can't do that.
- `output`: shows values after apply, and lets other folders read them.
- Data sources read things that already exist: `aws_ami`, `aws_availability_zones`, `aws_caller_identity`.

### 5. A real AWS network

- VPC, public subnet, internet gateway, route table and association, security group.
- Implicit dependency: a reference sets the order. `depends_on` only when there's no reference.
- `count` for on/off or identical copies. `for_each` for named items, because removing one item doesn't shift the others.
- `user_data` installs software when the server first starts.

### 6. State

- State maps code to real resources, like a warehouse inventory book.
- Never commit state: it can hold secrets, has no locking, and causes merge conflicts.
- S3 backend with `encrypt = true` and `use_lockfile = true` (older setups use DynamoDB). Versioning on the bucket allows rollback.
- The backend is built into Terraform Core, not a resource. It can't use variables, so use `-backend-config` (partial config).
- `.terraform/terraform.tfstate` remembers the backend address. That's why a new machine needs `init`.
- The bucket that holds state is made by a folder whose own state stays local.
- `init -migrate-state` copies state to a new backend. `init -reconfigure` just forgets the old one.
- `state list`, `state show`, `plan -refresh-only` for drift.
- Old command vs new block: `state mv` → `moved`, `terraform import` → `import`, `state rm` → `removed`.
- `import` + `plan -generate-config-out=generated.tf` writes the code for an existing resource.
- After the import is applied, the `import` block does nothing. Real teams delete `imports.tf` and move the useful parts of `generated.tf` into normal files. In this repo we keep them, with a comment, so the lesson stays visible.
- `removed { lifecycle { destroy = false } }`: Terraform forgets the resource but leaves it in AWS.
- `force-unlock` removes a stuck lock.
- Why teams need remote state even with CI: CI runners are temporary, plan and apply run on different machines, locking stops two applies at once.

### 7. Modules and repo layout

- A module is like a function: variables are inputs, outputs are return values.
- Every folder is a module. The one you run is the root module.
- A module can only get values through its variables. It can't see the caller's data sources.
- Local module: `source = "../../modules/x"`, no version. Registry module: always set `version`.
- Run `init` again after adding a module or changing its version.
- Modules don't configure providers. A module with a provider block can't use `count` or `for_each`.
- `terraform_remote_state` reads only the outputs of another state. Unlike a backend, it can use variables.
- Workspaces: same code, separate state. In S3 the key gets an `env:/<name>/` prefix. `default` can't be deleted. `terraform.workspace` is an expression, not a command.
- Real teams use folders per environment, not workspaces, so you can't apply to prod by mistake.
- HCP Terraform workspaces are a different thing from CLI workspaces.

**Layout decisions (2026-11-23)**

- `bootstrap/` sits at the top, not in `global/`. Not because S3 is regional, but because its lifecycle is different: local state, runs once, before everything else.
- `global/` means "shared by every env in the account" (for example IAM), not "AWS global service".
- Split components by lifecycle, not by AWS service: `network/` (rarely changes), `data/` (stateful, protect it), `app/` (changes often). An app's SG and IAM role stay with the app.
- Splitting every AWS service into its own folder creates many cross-state dependencies. Teams that do it often use Terragrunt.
- IAM: account-level roles and policies go in `global/iam/`. A role that belongs to one app stays with that app.
- DynamoDB locking is deprecated since Terraform 1.11. Use `use_lockfile = true`. Still know it for the exam.

### 8. Pro practices

**lifecycle**

- `create_before_destroy`: only matters on replace. Makes the new one first. Needs a unique name, so use `name_prefix`.
- `ignore_changes`: works on every plan. Terraform ignores changes to those attributes.
- `prevent_destroy`: stops any plan that would delete the resource. Removing the whole block from code removes the protection too.
- Others: `replace_triggered_by`, `precondition`, `postcondition`.
- `terraform apply -replace=<address>` replaces `terraform taint`.
- Values inside `lifecycle` must be literal. No variables.
- Don't change servers by hand. Anything not in code is lost when the server is replaced ("cattle, not pets").
