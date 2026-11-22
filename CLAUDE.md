# CLAUDE.md

Instructions for Claude Code in this repo. Course progress and notes are in the learning log:

@docs/learning-log.md

## Project

Terraform on AWS, laid out the way real teams do it.

- Region: `ap-south-1` (Mumbai)
- Terraform `>= 1.11` (needed for `use_lockfile`), AWS provider `~> 6.0`
- Layout: env first, then component

```
modules/web-server/      reusable SG + EC2 + nginx
global/state-bootstrap/  S3 state bucket (its own state stays local)
dev/  stag/  prod/       each has network/ and app/
```

- Each env folder has its own state key: `<env>/<component>/terraform.tfstate`
- `network` uses the Registry VPC module (3 public subnets, one per AZ)
- `app` reads `network` outputs with `terraform_remote_state` and calls `modules/web-server`
- CIDRs: dev `10.0.0.0/16`, stag `10.2.0.0/16`, prod `10.1.0.0/16`
- SSH is on in dev only. stag is a copy of prod.

## Commands

```bash
terraform init -backend-config=../../backend.hcl    # first time in an env folder
terraform init -backend-config=../../backend.hcl -reconfigure   # after the bucket changes
terraform fmt -recursive
terraform validate
```

`backend.hcl` and `*.tfvars` are gitignored. Use the `.example` files.

## Rules

- Only `dev` gets applied. `stag` and `prod` are there to compare. Never apply them unless asked.
- Apply `network` before `app`. Destroy `app` before `network`.
- Don't remove `prevent_destroy` from the state bucket unless asked.
- Never put account IDs, IPs or keys in committed files. Use placeholders like `<account_id>`.
- Keep resources small (`t3.micro`, no NAT gateway). The AWS account is paid, so destroy after each session.
- Modules have no `provider` block and use `>=` for provider versions.
- Every folder has a README. Update it when the folder changes.

## Writing style

- Code comments, READMEs and commit messages in plain, easy English. Readers are not native English speakers.
- Comments: 1-3 short lines. For `lifecycle` rules, say when the rule takes effect.

## Git

- Don't commit right after a change. Leave it uncommitted so the diff can be reviewed. Commit only when asked.
- Format: `<emoji> <Type>: <short description>`, for example `✨ Feature: add staging environment`
- Types: 🎉 Init, ✏️ Add, ✨ Feature, 🆙 Update, 🐛 Fix, 🔨 Refactor, 🔥 Remove, 📝 Docs, 🎨 Style (code formatting), 💡 Comment, 🚀 CI, 🧹 Chore
- One type per commit. No co-author lines. The owner pushes.

## Working with Claude

- This repo is also a course. Teach one step at a time: explain, show working code, then give a small hands-on task.
- Explain in Bangla with simple analogies. Keep answers to follow-up questions short.
- Create and edit files, but let the user run `init`, `plan`, `apply` and `destroy` unless asked. Go through each plan output together.
- Many questions are about how real teams do things. Answer that, then come back to the plan.
- Add Terraform Associate exam tips to each new topic.
