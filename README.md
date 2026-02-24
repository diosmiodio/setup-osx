# setup-osx

A single script to set up a fresh macOS machine with applications, CLI tools, shell aliases, preferences, and git accounts. Supports both personal and work configurations.

## Quick Start

```bash
git clone <this-repo> && cd setup-osx
bash setup.sh
```

The script presents an interactive menu — use arrow keys to navigate and Enter to select.

## How It Works

On launch you'll be asked two questions:

1. **Is this a work machine?** — Determines whether work-specific options are shown.
2. **What would you like to set up?** — Choose a category or install everything at once.

### Personal Machine

| Option | What it does |
|--------|-------------|
| Applications | Installs all GUI apps and CLI tools via Homebrew |
| Preferences | Configures git defaults, shell aliases, Finder, and sound |
| Accounts | Walks through git identity and GitHub CLI authentication |
| All | Runs all three in order |

### Work Machine

All personal options plus additional work-specific categories:

| Option | What it does |
|--------|-------------|
| Work: Applications | Clones `fbsource` |
| Work: Preferences | Installs work-specific shell aliases |
| Work: Accounts | Placeholder for future work account setup |
| Install Everything | Runs all personal and work steps |

## What Gets Installed

### GUI Applications

| App | Cask |
|-----|------|
| Rectangle Pro | `rectangle-pro` |
| 1Password | `1password` |
| Sublime Text | `sublime-text` |
| TickTick | `ticktick` |
| iTerm2 | `iterm2` |
| Blender | `blender` |
| Godot | `godot` |
| Figma | `figma` |
| WebStorm | `webstorm` |
| Rider | `rider` |
| Discord | `discord` |
| Fork | `fork` |
| SteerMouse | `steermouse` |

### CLI Tools

| Tool | Description |
|------|-------------|
| `git` | Version control |
| `gh` | GitHub CLI |
| `jq` | JSON processor |
| `ripgrep` (`rg`) | Fast code search |
| `fzf` | Fuzzy finder |
| `uv` | Python package/project manager |
| `nvm` + Node.js LTS | Node version manager |
| Claude Code | Anthropic's CLI for Claude |

### Preferences

| Setting | Details |
|---------|---------|
| Git defaults | Default branch `main`, editor `nano` |
| Shell aliases | Appended to `~/.zshrc` (see [Aliases](#aliases) below) |
| Finder | Show path bar, show hidden files, list view, clear `.DS_Store` overrides |
| Sound | Enable volume change feedback sound |
| Dock | Instant auto-hide delay, animation duration 0.35s |
| SteerMouse | Imports saved mouse button and scroll preferences |
| Rectangle Pro | Restores window management config from saved JSON |

## Aliases

The setup installs shell aliases into `~/.zshrc` wrapped in guard comments so they can be updated on re-run without duplication.

After installing, run `source ~/.zshrc` or open a new terminal to activate them.

### Git

| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit -m` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `glog` | `git log --oneline --graph` |

### Navigation

| Alias | Command |
|-------|---------|
| `ll` | `ls -la` |
| `la` | `ls -A` |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `home` | `cd ~` |
| `dev` | `cd ~/dev` |
| `projects` | `cd ~/dev/projects` |

### Python / uv

| Alias | Command |
|-------|---------|
| `uvr` | `uv run` |
| `uvi` | `uv init` |
| `uva` | `uv add` |
| `py` | `python3` |

### Claude

| Alias | Command |
|-------|---------|
| `claude` | `cd ~/dev && claude` |

### Misc

| Alias | Command |
|-------|---------|
| `c` | `clear` |
| `reload` | `source ~/.zshrc` |
| `zshrc` | Open `~/.zshrc` in Sublime Text |

### Work Aliases

Installed only on work machines, in a separate guard block.

| Alias | Command |
|-------|---------|
| `mhs` | Checkout `remote/rl/worlds/stable` in fbsource and run UE editor |

### Built-in Help

Type `help` in your terminal to see available topics:

```
help aliases    All shell aliases
help git        Git aliases
help jq         JSON processor
help rg         ripgrep (fast code search)
help fzf        Fuzzy finder
help gh         GitHub CLI
help uv         Python package manager
```

## Git Account Setup

The Accounts step (`git-setup.sh`) handles git identity configuration and GitHub authentication.

**What it does:**

1. Detects existing git accounts (global config, `includeIf` entries, orphaned `.gitconfig-*` files).
2. Asks how many total accounts you want.
3. For a **single account** — sets it as the global git config.
4. For **multiple accounts** — lets you pick a default, then assigns each additional account to a directory using git's `includeIf.gitdir` feature. Repos cloned into that directory automatically use the matching identity.
5. Authenticates each account with `gh auth login`.

**Re-running is safe** — it detects existing configuration and only prompts for what's missing.

## Files

```
setup.sh          Main entry point — menu, installers, preferences
work-setup.sh     Work-specific steps, sourced by setup.sh
git-setup.sh      Interactive git identity and GitHub auth setup
aliases.sh        Personal shell aliases (appended to ~/.zshrc)
aliases-work.sh   Work shell aliases (appended to ~/.zshrc)
aliases.md        Alias and CLI tools reference
_preferences/     Saved app configs restored during Preferences setup
```

## Re-running

The script is idempotent. Already-installed apps and tools are detected and skipped. Aliases are replaced in-place using guard comments (`# --- mac-setup aliases ---`). Running it again on a configured machine will report most items as skipped.

## Install Notes

Some applications require post-install actions (e.g., a reboot). These are collected during the run and printed in a **Notes** section at the end of the summary:

```
================================
 Complete!
 Installed: 5
 Skipped:   12
 Failed:    0
================================

── Notes ──────────────────────
 • Run 'source ~/.zshrc' to use your aliases in this terminal session.
```

## Customizing

**Add a GUI app:** Add a `"cask:<name>"` entry to `app_steps` in `setup.sh` and a corresponding line in `get_app_name()`.

**Add a CLI tool:** Add a `"formula:<name>"` entry to `app_steps`.

**Add an install note:** Add a case to `get_install_note()` in `setup.sh`.

**Add a personal alias:** Edit `aliases.sh` and update the `help()` function to match.

**Add a work alias:** Edit `aliases-work.sh` and update the work section in the `help()` function in `aliases.sh`.
