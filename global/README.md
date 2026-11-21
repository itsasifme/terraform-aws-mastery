# global

Things that are shared by every environment and created only once per AWS account.

| Folder | What it does |
|---|---|
| [`state-bootstrap`](state-bootstrap) | S3 bucket that holds the state of every other folder |

Apply this before any environment. Destroy it last.
