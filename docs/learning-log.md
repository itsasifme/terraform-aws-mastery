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

### Where I am now

Module 8, part 1 (`lifecycle`). The code is in place:

- `ignore_changes = [ami]` on the server
- `name_prefix` + `create_before_destroy` on the security group
- `prevent_destroy` on the state bucket

Hands-on still to do:

1. `terraform plan -destroy` in `global/state-bootstrap` and see the error
2. Apply dev, change the SG description, and look for `+/-` in the plan
3. Destroy dev (app first)

### Next

- **Part 2:** secrets with SSM Parameter Store, `sensitive = true`
- **Part 3:** CI/CD with GitHub Actions: plan on pull request, apply on merge, OIDC instead of access keys, tflint and trivy
- Common mistakes and interview questions
- 30-question mock test for the exam (HCP Terraform needs separate study)

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

### 8. Pro practices

**lifecycle**

- `create_before_destroy`: only matters on replace. Makes the new one first. Needs a unique name, so use `name_prefix`.
- `ignore_changes`: works on every plan. Terraform ignores changes to those attributes.
- `prevent_destroy`: stops any plan that would delete the resource. Removing the whole block from code removes the protection too.
- Others: `replace_triggered_by`, `precondition`, `postcondition`.
- `terraform apply -replace=<address>` replaces `terraform taint`.
- Values inside `lifecycle` must be literal. No variables.
- Don't change servers by hand. Anything not in code is lost when the server is replaced ("cattle, not pets").
