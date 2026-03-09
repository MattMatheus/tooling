# tooling

Personal dotfiles and tool configurations. Source of truth for all symlinked tool configs across machines.

## Structure

```
dotfiles/
├── .github/workflows/validate.yml   # JSON/config validation CI
├── claude/code/
│   └── permissions-baseline.json    # Claude Code allow/deny rules
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

## Setup on a New Machine

```bash
# Clone
git clone git@github.com:MattMatheus/tooling.git ~/Workspace/repos/tooling

# Claude Code permissions
ln -s ~/Workspace/repos/tooling/dotfiles/claude/code/permissions-baseline.json ~/.claude/settings.json

# Zed
ln -s ~/Workspace/repos/tooling/dotfiles/zed/settings.json ~/.config/zed/settings.json

# Karabiner (use the profile matching your keyboard)
# Import the relevant JSON via Karabiner-Elements UI or CLI
```

## Notes

- `obsidian/vault-spec.json` is a declarative spec, not a live Obsidian config. Use it to bootstrap vault creation on a new machine.
- Karabiner configs are profile-specific — macbook profile for built-in keyboard, apex-pro for the external.
- Per-machine variation is intentional. This repo captures shared baseline config only.
