# --- mac-setup work aliases ---

# Meta Node, NPM, and Yarn
export PATH="$HOME/fbsource/xplat/third-party/node/bin:$PATH"
export PATH="$HOME/fbsource/xplat/third-party/yarn:$PATH"

# Meta
mhs() { (cd ~/fbsource && git checkout remote/rl/worlds/stable && rl --editor run); }
alias mhe='cd ~/fbsource_mhs/arvr/projects/teams/ouro/mhe'
alias oma='cd ~/fbsource_mhs/arvr/projects/teams/ouro/mhe/blueprints/ouro_multiplayer_action'

# Navigation
alias iw='cd ~/dev/projects/imagine-worlds'

# Claude
alias cld='clear && claude --dangerously-skip-permissions'
alias iwc='cd ~/dev/projects/imagine-worlds && clear && claude --dangerously-skip-permissions'

# --- end mac-setup work aliases ---
