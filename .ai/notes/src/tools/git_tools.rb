Ruby file defining Git tools:
- Commit: Creates git commits with message param (required), add_all and files params (optional)
- Status: Shows git working tree status
- Diff: Shows changes between commits with optional path and staged params
- Log: Shows commit logs with optional number, path, and format params
Each tool validates git repo existence, executes git command, and returns formatted output or error.