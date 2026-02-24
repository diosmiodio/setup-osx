#!/bin/bash

# macOS Setup Script
# Installs applications, CLI tools, and shell aliases via Homebrew

# ── Colors ───────────────────────────────────────────────

bold="\033[1m"
dim="\033[2m"
cyan="\033[36m"
white="\033[37m"
reset="\033[0m"

# ── Counters ──────────────────────────────────────────────

installed=0
skipped=0
failed=0
notes=()

mark_installed() { ((installed++)); }
mark_skipped()   { ((skipped++)); }
mark_failed()    { ((failed++)); }
add_note()       { notes+=("$1"); }

log()      { echo "         -> $1"; }
log_skip() { log "Already installed, skipping."; mark_skipped; }

# ── Menu ─────────────────────────────────────────────────

select_menu() {
    local options=("$@")
    local count=${#options[@]}
    local selected=0

    # Hide cursor
    tput civis 2>/dev/null

    # Restore cursor on exit
    trap 'tput cnorm 2>/dev/null' EXIT

    # Draw menu
    draw_menu() {
        # Move cursor up to redraw (skip on first draw)
        if [[ "$1" == "redraw" ]]; then
            tput cuu "$count" 2>/dev/null
        fi

        for i in "${!options[@]}"; do
            tput el 2>/dev/null  # clear line
            if [[ $i -eq $selected ]]; then
                printf "  ${cyan}${bold}❯ %s${reset}\n" "${options[$i]}"
            else
                printf "  ${dim}  %s${reset}\n" "${options[$i]}"
            fi
        done
    }

    draw_menu "first"

    # Read keypresses
    while true; do
        read -rsn1 key

        case "$key" in
            $'\x1b')  # escape sequence
                read -rsn2 seq
                case "$seq" in
                    '[A')  # up
                        ((selected--))
                        [[ $selected -lt 0 ]] && selected=$((count - 1))
                        ;;
                    '[B')  # down
                        ((selected++))
                        [[ $selected -ge $count ]] && selected=0
                        ;;
                esac
                draw_menu "redraw"
                ;;
            '')  # enter
                break
                ;;
        esac
    done

    # Show cursor
    tput cnorm 2>/dev/null
    trap - EXIT

    menu_result=$selected
}

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
        logi-options+) echo "logioptionsplus.app" ;;
    esac
}

get_install_note() {
    case "$1" in
        logi-options+) echo "Reboot required for Logi Options+ to take effect." ;;
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
                local note
                note="$(get_install_note "$1")"
                [[ -n "$note" ]] && add_note "$note"
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
    local pathbar show_hidden view_style prefs_changed=false
    pathbar="$(defaults read com.apple.finder ShowPathbar 2>/dev/null)"
    show_hidden="$(defaults read com.apple.finder AppleShowAllFiles 2>/dev/null)"
    view_style="$(defaults read com.apple.finder FXPreferredViewStyle 2>/dev/null)"

    if [[ "$pathbar" != "1" || "$show_hidden" != "1" || "$view_style" != "Nlsv" ]]; then
        defaults write com.apple.finder ShowPathbar -bool true
        defaults write com.apple.finder AppleShowAllFiles -bool true
        defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
        prefs_changed=true
    fi

    # Remove .DS_Store files in key directories so per-folder view overrides
    # are cleared and the default list view applies
    log "Clearing per-folder view settings..."
    for dir in "$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" "$HOME/dev"; do
        [[ -d "$dir" ]] && find "$dir" -name ".DS_Store" -delete 2>/dev/null
    done

    killall Finder 2>/dev/null

    if [[ "$prefs_changed" == true ]]; then
        log "Complete."
        mark_installed
    else
        log "View settings refreshed."
        mark_installed
    fi
}

configure_sound() {
    local feedback
    feedback="$(defaults read NSGlobalDomain com.apple.sound.beep.feedback 2>/dev/null)"

    if [[ "$feedback" == "1" ]]; then
        log_skip
        return
    fi

    defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool true

    log "Complete."
    mark_installed
}

configure_git_defaults() {
    local editor branch_changed=false editor_changed=false

    if [[ "$(git config --global init.defaultBranch 2>/dev/null)" != "main" ]]; then
        git config --global init.defaultBranch main
        branch_changed=true
    fi

    editor="$(git config --global core.editor 2>/dev/null)"
    if [[ "$editor" != "nano" ]]; then
        git config --global core.editor "nano"
        editor_changed=true
    fi

    if $branch_changed || $editor_changed; then
        log "Complete."
        mark_installed
    else
        log_skip
    fi
}

install_aliases() {
    local zshrc="$HOME/.zshrc"
    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"

    if grep -q "# --- mac-setup aliases ---" "$zshrc" 2>/dev/null; then
        log "Updating aliases in ~/.zshrc..."
        # Remove the old block (everything between the guard comments, inclusive)
        sed -i '' '/^# --- mac-setup aliases ---$/,/^# --- end mac-setup aliases ---$/d' "$zshrc"
    else
        log "Adding to ~/.zshrc..."
    fi

    cat "$script_dir/aliases.sh" >> "$zshrc"
    log "Complete."
    mark_installed
}

# ── Steps ─────────────────────────────────────────────────

app_steps=(
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
    "cask:logi-options+"
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
)

pref_steps=(
    "custom:git-defaults"
    "custom:aliases"
    "custom:finder"
    "custom:sound"
)

# ── Runners ──────────────────────────────────────────────

run_step() {
    local type="${1%%:*}"
    local name="${1#*:}"

    case "$type" in
        cask)    install_cask "$name" ;;
        formula) install_formula "$name" ;;
        custom)
            case "$name" in
                uv)           install_uv ;;
                nvm)          install_nvm ;;
                claude-code)  install_claude_code ;;
                git-defaults) configure_git_defaults ;;
                aliases)      install_aliases ;;
                finder)       configure_finder ;;
                sound)        configure_sound ;;
            esac
            ;;
    esac
}

run_steps() {
    eval 'local steps=("${'"$1"'[@]}")'
    local total=${#steps[@]}
    local current=0

    echo ""
    for step in "${steps[@]}"; do
        local name="${step#*:}"
        ((current++))
        echo "[$current/$total] $name"
        run_step "$step"
        echo ""
    done
}

aliases_changed=false

run_applications() {
    setup_homebrew
    run_steps app_steps
}

run_preferences() {
    aliases_changed=true
    run_steps pref_steps
}

run_account_setup() {
    echo ""
    echo "────────────────────────────────"
    echo " Account Setup"
    echo "────────────────────────────────"
    echo ""

    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    bash "$script_dir/git-setup.sh"
}

print_summary() {
    if [[ $((installed + skipped + failed)) -gt 0 ]]; then
        echo "================================"
        echo " Complete!"
        echo " Installed: $installed"
        echo " Skipped:   $skipped"
        echo " Failed:    $failed"
        echo "================================"
    fi

    if [[ "$aliases_changed" == true ]]; then
        add_note "Run 'source ~/.zshrc' to use your aliases in this terminal session."
    fi

    if [[ ${#notes[@]} -gt 0 ]]; then
        echo ""
        echo "── Notes ──────────────────────"
        for note in "${notes[@]}"; do
            printf " ${dim}• %s${reset}\n" "$note"
        done
    fi

    echo ""
}

# ── Main ──────────────────────────────────────────────────

echo ""
printf "  ${bold}${white}┃ Setup ┃${reset}\n"
echo ""

printf "  ${bold}Is this a work machine?${reset}\n"
echo ""
select_menu "Yes" "No"
is_work=$menu_result

echo ""

if [[ $is_work -eq 0 ]]; then
    # Source work-specific setup functions
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    source "$script_dir/work-setup.sh"

    printf "  ${bold}${white}What would you like to set up?${reset}\n"
    echo ""
    select_menu \
        "Personal: Applications" \
        "Personal: Preferences" \
        "Personal: Accounts" \
        "Personal: All" \
        "Work: Applications" \
        "Work: Preferences" \
        "Work: Accounts" \
        "Work: All" \
        "Install Everything"

    echo ""

    case $menu_result in
        0) run_applications ;;
        1) run_preferences ;;
        2) run_account_setup ;;
        3)
            run_applications
            run_preferences
            run_account_setup
            ;;
        4) run_work_applications ;;
        5) run_work_preferences ;;
        6) run_work_account_setup ;;
        7)
            run_work_applications
            run_work_preferences
            run_work_account_setup
            ;;
        8)
            run_applications
            run_preferences
            run_account_setup
            run_work_applications
            run_work_preferences
            run_work_account_setup
            ;;
    esac
else
    printf "  ${bold}${white}What would you like to set up?${reset}\n"
    echo ""
    select_menu "Applications" "Preferences" "Accounts" "All"

    echo ""

    case $menu_result in
        0) run_applications ;;
        1) run_preferences ;;
        2) run_account_setup ;;
        3)
            run_applications
            run_preferences
            run_account_setup
            ;;
    esac
fi

print_summary
