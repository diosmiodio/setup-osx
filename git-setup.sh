#!/bin/bash

# Git Account Setup Script
# Configures git identity and GitHub authentication
# Supports single or multiple accounts with directory-based switching
#
# Default account: set as global git config, used everywhere
# Additional accounts: scoped to specific directories via includeIf

log() { echo "  -> $1"; }

# ── Detect existing accounts ──

acct_names=()
acct_emails=()
acct_labels=()
acct_dirs=()

global_name="$(git config --global user.name 2>/dev/null)"
global_email="$(git config --global user.email 2>/dev/null)"

include_lines="$(git config --global --get-regexp 'includeif\..*\.path' 2>/dev/null || true)"

# Collect includeIf accounts
if [[ -n "$include_lines" ]]; then
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        cfg="${line##* }"
        [[ ! -f "$cfg" ]] && continue
        name="$(git config --file "$cfg" user.name 2>/dev/null)"
        email="$(git config --file "$cfg" user.email 2>/dev/null)"
        dir="$(echo "$line" | sed 's/includeif\.gitdir:\(.*\)\.path.*/\1/')"
        label="$(basename "$cfg" | sed 's/\.gitconfig-//')"
        acct_names+=("$name")
        acct_emails+=("$email")
        acct_labels+=("$label")
        acct_dirs+=("$dir")
    done <<< "$include_lines"
fi

# Collect global account if not already covered by an includeIf
if [[ -n "$global_name" && -n "$global_email" ]]; then
    already_listed=false
    for e in "${acct_emails[@]}"; do
        [[ "$e" == "$global_email" ]] && already_listed=true && break
    done
    if ! $already_listed; then
        acct_names+=("$global_name")
        acct_emails+=("$global_email")
        acct_labels+=("global")
        acct_dirs+=("")
    fi
fi

# Collect orphaned ~/.gitconfig-* files not referenced by any includeIf
for cfg_file in "$HOME"/.gitconfig-*; do
    [[ ! -f "$cfg_file" ]] && continue
    name="$(git config --file "$cfg_file" user.name 2>/dev/null)"
    email="$(git config --file "$cfg_file" user.email 2>/dev/null)"
    [[ -z "$name" || -z "$email" ]] && continue
    already_listed=false
    for e in "${acct_emails[@]}"; do
        [[ "$e" == "$email" ]] && already_listed=true && break
    done
    if ! $already_listed; then
        label="$(basename "$cfg_file" | sed 's/\.gitconfig-//')"
        acct_names+=("$name")
        acct_emails+=("$email")
        acct_labels+=("$label")
        acct_dirs+=("")
    fi
done

existing=${#acct_names[@]}

# ── Show existing accounts ──

if [[ $existing -gt 0 ]]; then
    log "Found $existing existing git account(s):"
    for ((i = 0; i < existing; i++)); do
        if [[ -z "${acct_dirs[$i]}" || "${acct_dirs[$i]}" == "/" ]]; then
            log "  $((i+1)). ${acct_names[$i]} <${acct_emails[$i]}> (default)"
        else
            log "  $((i+1)). ${acct_names[$i]} <${acct_emails[$i]}> → ${acct_dirs[$i]}"
        fi
    done
fi

# ── How many accounts? ──

echo ""
read -rp "  -> How many total git accounts do you want? (0 to skip): " desired

if [[ "$desired" == "0" ]]; then
    log "Skipping."
    exit 0
fi

git config --global init.defaultBranch main

to_add=$((desired - existing))
[[ $to_add -lt 0 ]] && to_add=0

# ── Add new accounts ──

if [[ $to_add -gt 0 ]]; then
    for ((i = 1; i <= to_add; i++)); do
        echo ""
        log "── New account $i of $to_add ──"
        read -rp "  -> Label (e.g. personal, work): " label
        read -rp "  -> Full name: " name
        read -rp "  -> Email: " email
        acct_names+=("$name")
        acct_emails+=("$email")
        acct_labels+=("$label")
        acct_dirs+=("")
    done
fi

total=${#acct_names[@]}

# ── Single account ──

if [[ $total -eq 1 ]]; then
    git config --global user.name "${acct_names[0]}"
    git config --global user.email "${acct_emails[0]}"
    log "Configured: ${acct_names[0]} <${acct_emails[0]}>"
else
    # ── Multiple accounts: pick default + assign directories ──

    echo ""
    log "Which account should be the default on this machine?"
    log "(Used everywhere unless a repo is in a specific directory)"
    echo ""
    for ((i = 0; i < total; i++)); do
        echo "         $((i+1)). ${acct_names[$i]} <${acct_emails[$i]}>"
    done
    echo ""
    read -rp "  -> Default account number: " default_num
    default_idx=$((default_num - 1))

    # Clean up existing includeIf entries managed by this script
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        key="${line%% *}"
        value="${line#* }"
        if [[ "$value" == "$HOME/.gitconfig-"* ]]; then
            git config --global --unset "$key" 2>/dev/null || true
        fi
    done < <(git config --global --get-regexp 'includeif\..*\.path' 2>/dev/null || true)

    # Set default as global config
    git config --global user.name "${acct_names[$default_idx]}"
    git config --global user.email "${acct_emails[$default_idx]}"
    echo ""
    log "Default: ${acct_names[$default_idx]} <${acct_emails[$default_idx]}>"

    # Configure non-default accounts with directory scoping
    for ((i = 0; i < total; i++)); do
        [[ $i -eq $default_idx ]] && continue

        dir="${acct_dirs[$i]}"

        # Prompt for directory if not set or was "/" (catch-all from old config)
        if [[ -z "$dir" || "$dir" == "/" ]]; then
            echo ""
            read -rp "  -> Directory for ${acct_names[$i]} <${acct_emails[$i]}> (e.g. ~/dev/work): " dir
            dir="${dir/#\~/$HOME}"
        fi
        [[ "$dir" != */ ]] && dir="$dir/"
        mkdir -p "$dir"

        label="${acct_labels[$i]}"
        cfg="$HOME/.gitconfig-$label"
        git config --file "$cfg" user.name "${acct_names[$i]}"
        git config --file "$cfg" user.email "${acct_emails[$i]}"
        git config --global --add "includeIf.gitdir:$dir.path" "$cfg"
        log "${acct_names[$i]} <${acct_emails[$i]}> → $dir"
    done

    echo ""
    log "── How it works ──"
    log "Your default account is used everywhere."
    log "Repos inside a specific directory use that directory's account."
    log "Just clone/create repos in the matching directory."
    log "To switch GitHub CLI accounts: gh auth switch"
fi

# ── GitHub authentication ──

echo ""
gh_count=$(gh auth status 2>&1 | grep -c "Logged in to" || true)

if [[ $gh_count -lt $total ]]; then
    auth_needed=$((total - gh_count))
    for ((i = 1; i <= auth_needed; i++)); do
        log "Authenticating GitHub account ($((gh_count + i)) of $total)..."
        gh auth login -p https -h github.com -w
        echo ""
    done
else
    log "Already authenticated with GitHub."
fi

log "Done."
