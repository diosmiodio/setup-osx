# Global Shell Aliases

These aliases will be added to `~/.zshrc` by the setup script.

## Git

| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Show working tree status |
| `ga` | `git add` | Stage files (e.g. `ga .` or `ga file.txt`) |
| `gc` | `git commit -m` | Commit with message (e.g. `gc "fix bug"`) |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull from remote |
| `gd` | `git diff` | Show unstaged changes |
| `gco` | `git checkout` | Switch branches (e.g. `gco main`) |
| `gb` | `git branch` | List or create branches |
| `glog` | `git log --oneline --graph` | Compact visual commit history |

## Navigation

| Alias | Command | Description |
|-------|---------|-------------|
| `ll` | `ls -la` | List all files in long format |
| `la` | `ls -A` | List all files including hidden |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `dev` | `cd ~/dev` | Jump to dev directory |
| `projects` | `cd ~/dev/projects` | Jump to projects directory |

## Python / uv

| Alias | Command | Description |
|-------|---------|-------------|
| `uvr` | `uv run` | Run a command in the project's virtual env |
| `uvi` | `uv init` | Initialize a new Python project |
| `uva` | `uv add` | Add a dependency |
| `py` | `python3` | Shortcut for python3 |

## Misc

| Alias | Command | Description |
|-------|---------|-------------|
| `c` | `clear` | Clear terminal |
| `reload` | `source ~/.zshrc` | Reload shell config |
| `zshrc` | `open ~/.zshrc -a "Sublime Text"` | Edit shell config in Sublime |

---

## CLI Tools Reference

These are installed by the setup script. Not aliases — standalone commands.

### jq — JSON processor

Process and filter JSON from the command line.

```bash
# Pretty-print JSON
curl -s https://api.example.com/data | jq .

# Extract a specific field
echo '{"name": "Jo", "age": 30}' | jq '.name'

# Filter an array
cat data.json | jq '.users[] | select(.active == true)'
```

### ripgrep (rg) — fast code search

Search file contents recursively. Much faster than `grep`.

```bash
# Search for a string in current directory
rg "TODO"

# Search only in .ts files
rg "function" --type ts

# Search with context (3 lines before/after)
rg "error" -C 3

# Case-insensitive search
rg -i "config"
```

### fzf — fuzzy finder

Interactive fuzzy search. Integrates with your shell.

```bash
# Fuzzy find a file
fzf

# Pipe any list into fzf
ls | fzf

# Search command history (Ctrl+R is enhanced automatically)
# Open a file in Sublime
sublime $(fzf)

# Combined with ripgrep: search code then pick a result
rg --files | fzf
```

### gh — GitHub CLI

Manage GitHub repos, PRs, and issues from the terminal.

```bash
# Clone a repo
gh repo clone owner/repo

# Create a pull request
gh pr create --title "My PR" --body "Description"

# List open PRs
gh pr list

# View an issue
gh issue view 42

# Create a repo
gh repo create my-project --private
```

### uv — Python package manager

Fast Python project and dependency management.

```bash
# Create a new project
uv init my-project

# Add a dependency
uv add requests

# Run a script in the project env
uv run python main.py

# Install from requirements
uv pip install -r requirements.txt
```
