# tooling

Personal dotfiles and tool configurations. Source of truth for all symlinked tool configs across machines.

## Structure

```
dotfiles/
├── .github/workflows/validate.yml   # JSON/config validation CI
├── claude/code/
│   └── permissions-baseline.json    # Claude Code allow/deny rules
│   └── permissions-linux-bootstrap.json
├── karabiner/
│   ├── macbook/karabiner-macbook.json
│   └── apex-pro/karabiner-apex-pro.json
├── obsidian/
│   └── vault-spec.json              # Vault definitions (spec, not live config)
└── zed/
    └── settings.json                # Zed editor settings
```

## Symlink Pattern

All live configs are symlinked from this repo to their expected locations. This keeps the repo as the single source of truth — edit here, changes are immediately active.

| Config | Symlink Target |
|--------|---------------|
| `claude/code/permissions-baseline.json` | `~/.claude/settings.json` |
| `zed/settings.json` | `~/.config/zed/settings.json` |

For Linux machine bootstrap, you can temporarily point `~/.claude/settings.json` at `claude/code/permissions-linux-bootstrap.json` instead of the baseline file.

## Setup on a New Machine

```bash
# Clone or place the repo somewhere under ~/Workspace/repos/
git clone git@github.com:MattMatheus/tooling.git ~/Workspace/repos/tooling

# Git identity
git config --global user.name "matt.matheus"
git config --global user.email "matt.matheus@outlook.com"

# Claude Code permissions (baseline)
mkdir -p ~/.claude
ln -s ~/Workspace/repos/tooling/dotfiles/claude/code/permissions-baseline.json ~/.claude/settings.json

# Claude Code permissions (Mint/Linux bootstrap profile)
ln -s ~/Workspace/repos/tooling/dotfiles/claude/code/permissions-linux-bootstrap.json ~/.claude/settings.json

# Zed
mkdir -p ~/.config/zed
ln -s ~/Workspace/repos/tooling/dotfiles/zed/settings.json ~/.config/zed/settings.json

# Karabiner (macOS only; use the profile matching your keyboard)
# Import the relevant JSON via Karabiner-Elements UI or CLI
```

If the repo lives at a different path on a given machine, substitute that path in the symlink commands. On this Mint machine the current path is `~/Workspace/repos/trusted/tooling`.

## Notes

- `obsidian/vault-spec.json` is a declarative spec, not a live Obsidian config. Use it to bootstrap vault creation on a new machine.
- Karabiner configs are profile-specific — macbook profile for built-in keyboard, apex-pro for the external.
- `claude/code/permissions-baseline.json` is the day-to-day safe default; `claude/code/permissions-linux-bootstrap.json` is the broader Mint bootstrap profile for package install and local AI stack bring-up.
- The Zed toggle-Vim shortcut uses `ctrl-alt-shift-v` so the baseline works on Linux and macOS without a Command key dependency.
- Per-machine variation is intentional. This repo captures shared baseline config only.
