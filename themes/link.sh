#!/usr/bin/env bash
# =============================================================================
# link.sh — wire generated theme files to tool config directories (macOS)
#
# Run this once after cloning the tooling repo, and again after adding
# new tools. Safe to re-run — existing correct symlinks are left alone,
# wrong targets are re-pointed, plain files will not be clobbered (exits).
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
OBSIDIAN_VAULTS=(
    "$HOME/AgenticDevelopment/Knowledge/Vaults/HCAT"
    # "/Users/$USER/Documents/NotesVault"
    # "/Users/$USER/AnotherVault"
)
TEMP_VAULTS=()

# macOS can also store app configs under ~/Library/Application Support.
if [[ "$OSTYPE" == darwin* ]]; then
    ZED_THEME_DIR="$HOME/Library/Application Support/Zed/themes"
else
    ZED_THEME_DIR="$CONFIG_DIR/zed/themes"
fi

# Terminal color helpers (minimal — no dependency on the theme being linked yet)
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }

# -----------------------------------------------------------------------------
# safe_link SRC DST
# Creates DST as a symlink pointing to SRC.
# - If DST is already a correct symlink: skip
# - If DST is a symlink to somewhere else: re-point
# - If DST is a real file: abort (don't silently nuke user config)
# -----------------------------------------------------------------------------
safe_link() {
    local src="$1"
    local dst="$2"

    if [[ ! -e "$src" ]]; then
        red "  MISSING source: $src"
        red "  → Run 'python3 generate.py' first"
        exit 1
    fi

    mkdir -p "$(dirname "$dst")"

    if [[ -L "$dst" ]]; then
        local current
        current="$(readlink "$dst")"
        if [[ "$current" == "$src" ]]; then
            yellow "  skip (already linked): $dst"
            return
        else
            echo "  re-pointing: $dst"
            ln -sf "$src" "$dst"
        fi
    elif [[ -e "$dst" ]]; then
        red "  CONFLICT: $dst exists and is not a symlink"
        red "  → Back it up and remove it, then re-run"
        exit 1
    else
        ln -s "$src" "$dst"
        green "  linked: $dst → $src"
    fi
}

safe_link_obsidian() {
    local vault_dir="$1"
    local snippets_dir="${vault_dir}/.obsidian/snippets"

    if [[ ! -d "$vault_dir" ]]; then
        yellow "  skip (missing vault): $vault_dir"
        return
    fi

    mkdir -p "$snippets_dir"
    safe_link \
        "$THEMES_DIR/obsidian/calm.css" \
        "$snippets_dir/calm.css"
}

usage() {
    cat <<EOF
Usage: bash link.sh [VAULT_PATH ...]
       bash link.sh --once VAULT_PATH [VAULT_PATH ...]

Links theme files and optionally links Obsidian snippets for vault paths.

Without --once, any VAULT_PATH arguments are added to the default list.
With --once, only the provided VAULT_PATH arguments are used for Obsidian snippets.

Examples:
  bash link.sh
  bash link.sh /Users/you/TempVault
  bash link.sh /Users/you/VaultA /Users/you/VaultB
  bash link.sh --once /Users/you/TempVault
  bash link.sh --once /Users/you/VaultA /Users/you/VaultB
EOF
}

USE_ONLY_ARGS=0
for vault_arg in "$@"; do
    if [[ "$vault_arg" == "-h" || "$vault_arg" == "--help" ]]; then
        usage
        exit 0
    fi
done

for vault_arg in "$@"; do
    if [[ "$vault_arg" == "--once" ]]; then
        USE_ONLY_ARGS=1
        continue
    fi

    if [[ "$vault_arg" != --* ]]; then
        TEMP_VAULTS+=("$vault_arg")
    fi
done

# =============================================================================
# Link table — add rows here as new tools arrive
# Format: safe_link  <source in repo>  <destination expected by tool>
# =============================================================================

echo "Linking themes..."

 
# Ghostty
# Themes dir: ${CONFIG_DIR}/ghostty/themes/<name>.theme
# Config references it as: theme = calm
safe_link \
    "$THEMES_DIR/ghostty/calm.theme" \
    "$CONFIG_DIR/ghostty/themes/calm.theme"

# Zed
# Themes dir: macOS: ~/Library/Application Support/Zed/themes/<name>.json
#           else: ~/.config/zed/themes/<name>.json
# Available in theme selector after Zed reloads
safe_link \
    "$THEMES_DIR/zed/calm.json" \
    "$ZED_THEME_DIR/calm.json"

# Obsidian
# Obsidian snippets are stored inside vaults under .obsidian/snippets/calm.css
if [[ "$USE_ONLY_ARGS" -eq 1 ]]; then
    if [[ ${#TEMP_VAULTS[@]} -eq 0 ]]; then
        red "  --once was used with no vault paths"
        red "  usage: bash link.sh --once /path/to/vault"
        exit 1
    fi
fi

if [[ ${#TEMP_VAULTS[@]} -gt 0 ]]; then
    echo ""
    if [[ "$USE_ONLY_ARGS" -eq 1 ]]; then
        echo "Linking provided vault args only:"
        for v in "${TEMP_VAULTS[@]}"; do
            echo "  - $v"
        done
    else
        echo "Adding temporary vault args:"
        for v in "${TEMP_VAULTS[@]}"; do
            echo "  - $v"
        done
    fi
fi

if [[ "$USE_ONLY_ARGS" -eq 1 ]]; then
    for OBSIDIAN_VAULT_DIR in "${TEMP_VAULTS[@]}"; do
        safe_link_obsidian "$OBSIDIAN_VAULT_DIR"
    done
else
    for OBSIDIAN_VAULT_DIR in "${OBSIDIAN_VAULTS[@]}" "${TEMP_VAULTS[@]}"; do
        safe_link_obsidian "$OBSIDIAN_VAULT_DIR"
    done
fi

# -----------------------------------------------------------------------------
# Future tools (uncomment + adjust paths as you add renderers):
# -----------------------------------------------------------------------------
# btop
# safe_link "$THEMES_DIR/btop/calm.theme" "$HOME/.config/btop/themes/calm.theme"
#
# bat
# safe_link "$THEMES_DIR/bat/calm.tmTheme" "$HOME/.config/bat/themes/calm.tmTheme"
#
# delta (referenced from ~/.gitconfig, no symlink needed — path in config)
# safe_link "$THEMES_DIR/delta/calm.gitconfig" "$HOME/.config/delta/calm.gitconfig"
#
# starship
# safe_link "$THEMES_DIR/starship/calm.toml" "$HOME/.config/starship/calm.toml"

echo ""
green "Done. Reload each tool to pick up changes."
echo ""
echo "Ghostty: Cmd+Shift+, to reload config"
echo "Zed:     theme selector: Toggle in command palette"
