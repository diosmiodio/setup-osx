#!/bin/bash

# macOS Setup Script
# Installs applications, CLI tools, and shell aliases via Homebrew

# ── Counters ──────────────────────────────────────────────

installed=0
skipped=0
failed=0

mark_installed() { ((installed++)); }
mark_skipped()   { ((skipped++)); }
mark_failed()    { ((failed++)); }

log()      { echo "         -> $1"; }
log_skip() { log "Already installed, skipping."; mark_skipped; }

# ── Homebrew ──────────────────────────────────────────────

setup_homebrew() {
    # Ensure Homebrew is in PATH (Apple Silicon installs to /opt/homebrew)
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    if command -v brew &>/dev/null; then
        echo "Homebrew already installed."
    else
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi

    echo "Updating Homebrew..."
    brew update
}

# ── Installers ────────────────────────────────────────────

get_app_name() {
    case "$1" in
        rectangle-pro) echo "Rectangle Pro.app" ;;
        1password)     echo "1Password.app" ;;
        sublime-text)  echo "Sublime Text.app" ;;
        ticktick)      echo "TickTick.app" ;;
        iterm2)        echo "iTerm.app" ;;
        blender)       echo "Blender.app" ;;
        godot)         echo "Godot.app" ;;
        figma)         echo "Figma.app" ;;
        webstorm)      echo "WebStorm.app" ;;
        rider)         echo "Rider.app" ;;
        discord)       echo "Discord.app" ;;
        fork)          echo "Fork.app" ;;
    esac
}

is_cask_installed() {
    brew list --cask "$1" &>/dev/null && return 0
    local app_name
    app_name="$(get_app_name "$1")"
    [[ -n "$app_name" && -d "/Applications/$app_name" ]]
}

install_cask() {
    if is_cask_installed "$1"; then
        log_skip
    else
        log "Downloading..."
        if brew fetch --cask "$1" &>/dev/null; then
            log "Extracting..."
            if brew install --cask "$1" &>/dev/null; then
                log "Installing..."
                log "Complete."
                mark_installed
            else
                log "FAILED during install."
                mark_failed
            fi
        else
            log "FAILED during download."
            mark_failed
        fi
    fi
}

install_formula() {
    if brew list "$1" &>/dev/null; then
        log_skip
    else
        log "Installing..."
        if brew install "$1" &>/dev/null; then
            log "Complete."
            mark_installed
        else
            log "FAILED."
            mark_failed
        fi
    fi
}

install_uv() {
    if command -v uv &>/dev/null || [[ -f "$HOME/.local/bin/uv" ]]; then
        log_skip
    else
        log "Installing..."
        if curl -LsSf https://astral.sh/uv/install.sh | sh &>/dev/null; then
            log "Complete."
            mark_installed
        else
            log "FAILED."
            mark_failed
        fi
    fi
}

install_nvm() {
    if [[ -d "$HOME/.nvm" ]]; then
        log_skip
    else
        log "Installing nvm..."
        if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash &>/dev/null; then
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
            log "Installing Node.js LTS..."
            nvm install --lts &>/dev/null
            log "Complete."
            mark_installed
        else
            log "FAILED."
            mark_failed
        fi
    fi
}

install_claude_code() {
    if command -v claude &>/dev/null; then
        log_skip
    else
        log "Installing..."
        if npm install -g @anthropic-ai/claude-code &>/dev/null; then
            log "Complete."
            mark_installed
        else
            log "FAILED. (Requires Node.js)"
            mark_failed
        fi
    fi
}

configure_finder() {
    local pathbar show_hidden view_style
    pathbar="$(defaults read com.apple.finder ShowPathbar 2>/dev/null)"
    show_hidden="$(defaults read com.apple.finder AppleShowAllFiles 2>/dev/null)"
    view_style="$(defaults read com.apple.finder FXPreferredViewStyle 2>/dev/null)"

    if [[ "$pathbar" == "1" && "$show_hidden" == "1" && "$view_style" == "Nlsv" ]]; then
        log_skip
        return
    fi

    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    killall Finder 2>/dev/null

    log "Complete."
    mark_installed
}

install_aliases() {
    local zshrc="$HOME/.zshrc"
    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"

    if grep -q "# --- mac-setup aliases ---" "$zshrc" 2>/dev/null; then
        log "Already configured, skipping."
        mark_skipped
    else
        log "Adding to ~/.zshrc..."
        cat "$script_dir/aliases.sh" >> "$zshrc"
        log "Complete."
        mark_installed
    fi
}

# ── Steps ─────────────────────────────────────────────────

install_steps=(
    # GUI apps
    "cask:rectangle-pro"
    "cask:1password"
    "cask:sublime-text"
    "cask:ticktick"
    "cask:iterm2"
    "cask:blender"
    "cask:godot"
    "cask:figma"
    "cask:webstorm"
    "cask:rider"
    "cask:discord"
    "cask:fork"
    # CLI tools
    "formula:git"
    "formula:gh"
    "formula:jq"
    "formula:ripgrep"
    "formula:fzf"
    # Custom
    "custom:uv"
    "custom:nvm"
    "custom:claude-code"
    "custom:aliases"
    "custom:finder"
)

# ── Main ──────────────────────────────────────────────────

setup_homebrew

total=${#install_steps[@]}
current=0

echo ""
echo "Setting up $total items..."
echo ""

for step in "${install_steps[@]}"; do
    type="${step%%:*}"
    name="${step#*:}"
    ((current++))
    echo "[$current/$total] $name"

    case "$type" in
        cask)    install_cask "$name" ;;
        formula) install_formula "$name" ;;
        custom)
            case "$name" in
                uv)         install_uv ;;
                nvm)        install_nvm ;;
                claude-code) install_claude_code ;;
                aliases)    install_aliases ;;
                finder)     configure_finder ;;
            esac
            ;;
    esac
    echo ""
done

echo "================================"
echo " Install complete!"
echo " Installed: $installed"
echo " Skipped:   $skipped"
echo " Failed:    $failed"
echo "================================"

# ── Account Setup ────────────────────────────────────────

echo ""
echo "────────────────────────────────"
echo " Account Setup"
echo "────────────────────────────────"
echo ""

script_dir="$(cd "$(dirname "$0")" && pwd)"
bash "$script_dir/git-setup.sh"

echo ""
echo "Run 'source ~/.zshrc' or open a new terminal to use your aliases."
