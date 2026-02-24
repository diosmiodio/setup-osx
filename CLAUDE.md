# Claude Code Instructions for setup-osx

## Rules

- After completing any changes to this project, update `README.md` to reflect the current state.
- When adding, removing, or renaming entries in `aliases.sh`, always update the `help()` function in that same file to stay in sync.
- When adding, removing, or renaming entries in `aliases-work.sh`, update the Work section inside the `help()` function in `aliases.sh`.
- When adding a new cask to `app_steps` in `setup.sh`, also add a case to `get_app_name()`. If the app has post-install requirements, add a case to `get_install_note()`.
