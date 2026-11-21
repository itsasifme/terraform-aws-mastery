# modules

Reusable building blocks. Nothing here is applied directly: the environment folders call these modules and pass in their own values.

| Module | What it does | Used by |
|---|---|---|
| [`web-server`](web-server) | security group + EC2 with nginx | `dev/app`, `stag/app`, `prod/app` |

## Module conventions

These follow HashiCorp's guidance for reusable modules ([standard module structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure), [providers within modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)).

| Convention | Why |
|---|---|
| No `provider` block inside a module | The caller sets region and credentials, so one module works in any region or account. A module with its own provider block also can't be used with `count`, `for_each` or `depends_on`. |
| `required_providers` with a minimum version only (`>= 6.0`) | The root folder picks the actual version range with `~> 6.0`. A tight pin inside a module could clash with the caller's choice. |
| A description on every variable and output | It's the module's documentation, and tools like `terraform-docs` build the README from it. |
| Expose every value a caller might need as an output | Callers can only see a module's outputs, never its resources directly. |
| A README in every module | It's part of the standard module structure, and the Registry shows it as the module's front page. |
