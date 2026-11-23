# global

Account-wide things that don't belong to one environment, for example IAM.
"Global" here means "shared by all envs", not "an AWS global service".

| Folder | What it does |
|---|---|
| (empty for now) | `iam/` comes next: account-level roles and policies |

The state bucket is not here. It lives in [`bootstrap/`](../bootstrap) because it must exist before anything else and keeps its own state locally.
