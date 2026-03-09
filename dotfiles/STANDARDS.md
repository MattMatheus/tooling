# Dotfiles Standards

## Purpose

This repo is the source of truth for shared tool configuration that is symlinked into live locations on a machine. Changes here should be safe to apply directly and should prefer baseline defaults over machine-specific customization.

## Repository Standards

- Keep configs declarative and committed as plain JSON or YAML.
- Treat this repo as the editable source; live configs should remain symlinks.
- Capture only shared baseline behavior. Per-machine or per-device differences stay isolated in separate files or profiles.
- Prefer additive, low-risk defaults over destructive or environment-specific automation.
- New config areas must document their symlink target or activation path in `README.md`.

## Tooling Standards

### Claude Code permissions

- Default to read-oriented and inspection-oriented capabilities.
- Allow only narrowly scoped shell commands that support normal repo work.
- Explicitly deny destructive commands such as force-push, hard reset, recursive delete, and `sudo`.
- Expand permissions by adding specific command patterns, not broad wildcards.

### Zed settings

- Keep editor behavior minimal and portable.
- Preserve 2-space formatting defaults unless a tool-specific reason requires otherwise.
- Prefer settings that work across machines without local absolute paths.

### Obsidian vault spec

- Treat `vault-spec.json` as a declarative bootstrap spec, not live application state.
- Define vaults independently; do not assume shared `.obsidian` config.
- Keep structure, plugins, and quick-capture conventions consistent unless the vault purpose requires divergence.

### Karabiner profiles

- Store one file per keyboard/profile.
- Keep titles and rule descriptions human-readable.
- Avoid mixing profiles for built-in and external keyboards in one file.

## Validation Expectations

- Config files should remain valid JSON or YAML.
- Empty placeholders should be implemented before relying on them:
  - `.github/workflows/validate.yml`
  - `karabiner/apex-pro/karabiner-apex-pro.json`
- A validation workflow should at minimum parse all JSON files and fail on invalid syntax.

## Implementation Targets

1. Add CI validation in `.github/workflows/validate.yml` for JSON and YAML syntax.
2. Populate `karabiner/apex-pro/karabiner-apex-pro.json` with an explicit external-keyboard profile or remove it until needed.
3. Keep `README.md` aligned with any new config paths, symlink targets, or activation steps.
4. If new tools are added, create a dedicated directory per tool and document whether the file is live config, baseline config, or declarative spec.
