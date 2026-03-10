# --- mac-setup work aliases ---

# Meta Node, NPM, and Yarn
export PATH="$HOME/fbsource/xplat/third-party/node/bin:$PATH"
export PATH="$HOME/fbsource/xplat/third-party/yarn:$PATH"

# Meta
mhs() { (cd ~/fbsource && git checkout remote/rl/worlds/stable && rl --editor run); }

# --- end mac-setup work aliases ---
