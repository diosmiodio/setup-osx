#!/bin/bash

# Work-specific macOS Setup
# Sourced by setup.sh when a work machine is selected.
# Adds work-specific applications, aliases, and configurations
# on top of the personal setup.

# ── Work Installers ──────────────────────────────────────

clone_fbsource() {
    if [[ -d "$HOME/fbsource" ]]; then
        log_skip
    else
        log "Cloning fbsource (this may take a while)..."
        if fbclone fbsource; then
            log "Complete."
            mark_installed
        else
            log "FAILED."
            mark_failed
        fi
    fi
}

configure_claude_work() {
    local settings="$HOME/.claude/settings.json"

    if [[ ! -f "$settings" ]] || ! command -v jq &>/dev/null; then
        log "Skipping (no settings.json or jq missing)."
        mark_skipped
        return
    fi

    # Check if already using the work plugin
    local has_work_plugin
    has_work_plugin=$(jq -r '.enabledPlugins["superpowers@claude-templates"] // false' "$settings" 2>/dev/null)
    if [[ "$has_work_plugin" == "true" ]]; then
        log_skip
        return
    fi

    # Swap personal plugin for work plugin
    local tmp="$settings.tmp"
    jq '
      del(.enabledPlugins["superpowers@claude-plugins-official"])
      | .enabledPlugins["superpowers@claude-templates"] = true
    ' "$settings" > "$tmp" && mv "$tmp" "$settings"

    log "Complete."
    mark_installed
}

install_work_aliases() {
    local zshrc="$HOME/.zshrc"
    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"

    if grep -q "# --- mac-setup work aliases ---" "$zshrc" 2>/dev/null; then
        log "Updating work aliases in ~/.zshrc..."
        sed -i '' '/^# --- mac-setup work aliases ---$/,/^# --- end mac-setup work aliases ---$/d' "$zshrc"
    else
        log "Adding work aliases to ~/.zshrc..."
    fi

    # Insert work aliases after personal aliases block (so work overrides win)
    if grep -q "# --- end mac-setup aliases ---" "$zshrc" 2>/dev/null; then
        sed -i '' "/^# --- end mac-setup aliases ---$/r $script_dir/aliases-work.sh" "$zshrc"
    else
        cat "$script_dir/aliases-work.sh" >> "$zshrc"
    fi
    log "Complete."
    mark_installed
}

# ── Work Steps ───────────────────────────────────────────

work_app_steps=(
    "custom:fbsource"
)

work_pref_steps=(
    "custom:claude-work"
    "custom:work-aliases"
)

# ── Work Step Runner ─────────────────────────────────────

run_work_step() {
    local type="${1%%:*}"
    local name="${1#*:}"

    case "$type" in
        cask)    install_cask "$name" ;;
        formula) install_formula "$name" ;;
        custom)
            case "$name" in
                fbsource)     clone_fbsource ;;
                claude-work)  configure_claude_work ;;
                work-aliases) install_work_aliases ;;
            esac
            ;;
    esac
}

run_work_steps() {
    eval 'local steps=("${'"$1"'[@]}")'
    local total=${#steps[@]}
    local current=0

    if [[ $total -eq 0 ]]; then
        echo ""
        echo "  No work steps configured yet."
        echo ""
        return
    fi

    echo ""
    for step in "${steps[@]}"; do
        local name="${step#*:}"
        ((current++))
        echo "[$current/$total] $name"
        run_work_step "$step"
        echo ""
    done
}

# ── Work Runners ─────────────────────────────────────────

run_work_applications() {
    if [[ ${#work_app_steps[@]} -gt 0 ]]; then
        setup_homebrew
    fi
    run_work_steps work_app_steps
}

run_work_preferences() {
    aliases_changed=true
    run_work_steps work_pref_steps
}

run_work_account_setup() {
    echo ""
    echo "────────────────────────────────"
    echo " Work Account Setup"
    echo "────────────────────────────────"
    echo ""
    echo "  No work account setup configured yet."
    echo ""
}
