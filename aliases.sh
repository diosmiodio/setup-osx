
# --- mac-setup aliases ---

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph'

# Navigation
alias ll='ls -la'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'
alias dev='cd ~/dev'
alias projects='cd ~/dev/projects'

# Python / uv
alias uvr='uv run'
alias uvi='uv init'
alias uva='uv add'
alias py='python3'

# Claude
alias claude='cd ~/dev && claude'

# Misc
alias c='clear'
alias reload='source ~/.zshrc'
alias zshrc='open ~/.zshrc -a "Sublime Text"'

# Help
help() {
  case "$1" in
    alias|aliases)
      echo ""
      echo "  \033[1;36mGit\033[0m"
      echo "    gs     git status                  Show working tree status"
      echo "    ga     git add                     Stage files (e.g. ga . or ga file.txt)"
      echo "    gc     git commit -m               Commit with message (e.g. gc \"fix bug\")"
      echo "    gp     git push                    Push to remote"
      echo "    gl     git pull                    Pull from remote"
      echo "    gd     git diff                    Show unstaged changes"
      echo "    gco    git checkout                Switch branches (e.g. gco main)"
      echo "    gb     git branch                  List or create branches"
      echo "    glog   git log --oneline --graph   Compact visual commit history"
      echo ""
      echo "  \033[1;36mNavigation\033[0m"
      echo "    ll     ls -la                      List all files in long format"
      echo "    la     ls -A                       List all including hidden"
      echo "    ..     cd ..                       Go up one directory"
      echo "    ...    cd ../..                    Go up two directories"
      echo "    home   cd ~                        Jump to home directory"
      echo "    dev    cd ~/dev                    Jump to dev directory"
      echo "    projects  cd ~/dev/projects        Jump to projects directory"
      echo ""
      echo "  \033[1;36mPython / uv\033[0m"
      echo "    uvr    uv run                      Run command in project venv"
      echo "    uvi    uv init                     Initialize a new Python project"
      echo "    uva    uv add                      Add a dependency"
      echo "    py     python3                     Shortcut for python3"
      echo ""
      echo "  \033[1;36mClaude\033[0m"
      echo "    claude cd ~/dev && claude          Open Claude Code in ~/dev"
      echo ""
      echo "  \033[1;36mMisc\033[0m"
      echo "    c      clear                       Clear terminal"
      echo "    reload source ~/.zshrc             Reload shell config"
      echo "    zshrc  open ~/.zshrc               Edit shell config in Sublime"
      echo ""
      echo "  \033[1;36mWork (Meta)\033[0m"
      echo "    mhs    rl --editor run             Checkout stable tag & run UE editor"
      echo ""
      ;;
    git)
      echo ""
      echo "  \033[1;36mGit Aliases\033[0m"
      echo "    gs     git status"
      echo "    ga     git add"
      echo "    gc     git commit -m"
      echo "    gp     git push"
      echo "    gl     git pull"
      echo "    gd     git diff"
      echo "    gco    git checkout"
      echo "    gb     git branch"
      echo "    glog   git log --oneline --graph"
      echo ""
      ;;
    jq)
      echo ""
      echo "  \033[1;36mjq — JSON processor\033[0m"
      echo ""
      echo "  Pretty-print JSON:"
      echo "    curl -s https://api.example.com/data | jq ."
      echo ""
      echo "  Extract a specific field:"
      echo "    echo '{\"name\": \"Jo\", \"age\": 30}' | jq '.name'"
      echo ""
      echo "  Filter an array:"
      echo "    cat data.json | jq '.users[] | select(.active == true)'"
      echo ""
      ;;
    rg|ripgrep)
      echo ""
      echo "  \033[1;36mripgrep (rg) — fast code search\033[0m"
      echo ""
      echo "  Search for a string:"
      echo "    rg \"TODO\""
      echo ""
      echo "  Search only in .ts files:"
      echo "    rg \"function\" --type ts"
      echo ""
      echo "  Search with context (3 lines before/after):"
      echo "    rg \"error\" -C 3"
      echo ""
      echo "  Case-insensitive:"
      echo "    rg -i \"config\""
      echo ""
      ;;
    fzf)
      echo ""
      echo "  \033[1;36mfzf — fuzzy finder\033[0m"
      echo ""
      echo "  Fuzzy find a file:"
      echo "    fzf"
      echo ""
      echo "  Pipe any list into fzf:"
      echo "    ls | fzf"
      echo ""
      echo "  Open a file in Sublime:"
      echo "    sublime \$(fzf)"
      echo ""
      echo "  Search code then pick a result:"
      echo "    rg --files | fzf"
      echo ""
      ;;
    gh|github)
      echo ""
      echo "  \033[1;36mgh — GitHub CLI\033[0m"
      echo ""
      echo "  Clone a repo:"
      echo "    gh repo clone owner/repo"
      echo ""
      echo "  Create a pull request:"
      echo "    gh pr create --title \"My PR\" --body \"Description\""
      echo ""
      echo "  List open PRs:"
      echo "    gh pr list"
      echo ""
      echo "  View an issue:"
      echo "    gh issue view 42"
      echo ""
      echo "  Create a repo:"
      echo "    gh repo create my-project --private"
      echo ""
      ;;
    uv)
      echo ""
      echo "  \033[1;36muv — Python package manager\033[0m"
      echo ""
      echo "  Create a new project:"
      echo "    uv init my-project"
      echo ""
      echo "  Add a dependency:"
      echo "    uv add requests"
      echo ""
      echo "  Run a script in the project env:"
      echo "    uv run python main.py"
      echo ""
      echo "  Install from requirements:"
      echo "    uv pip install -r requirements.txt"
      echo ""
      ;;
    *)
      echo ""
      echo "  \033[1;36mUsage:\033[0m help <topic>"
      echo ""
      echo "  \033[1;33mTopics:\033[0m"
      echo "    aliases    All shell aliases"
      echo "    git        Git aliases"
      echo "    jq         JSON processor"
      echo "    rg         ripgrep (fast code search)"
      echo "    fzf        Fuzzy finder"
      echo "    gh         GitHub CLI"
      echo "    uv         Python package manager"
      echo ""
      ;;
  esac
}

# --- end mac-setup aliases ---
