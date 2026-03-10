#!/usr/bin/env bash
set -euo pipefail

TOOLING_ROOT="${TOOLING_ROOT:-$HOME/Workspace/repos/trusted/tooling}"
ATHENA_STACK_ROOT="${ATHENA_STACK_ROOT:-$HOME/Workspace/repos/trusted/athena-stack}"
ATHENAWORK_REMOTE="${ATHENAWORK_REMOTE:-git@github.com:MattMatheus/AthenaWork.git}"
GIT_USER_NAME="${GIT_USER_NAME:-matt.matheus}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-matt.matheus@outlook.com}"
CLAUDE_PROFILE="${CLAUDE_PROFILE:-linux-bootstrap}"
INSTALL_NVIDIA_TOOLKIT="${INSTALL_NVIDIA_TOOLKIT:-0}"

require_file() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo "missing required file: $path" >&2
    exit 1
  fi
}

link_config() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$source" "$target"
  printf 'linked %s -> %s\n' "$target" "$source"
}

write_athenactl_config() {
  mkdir -p "$HOME/.config/athenactl"
  cat >"$HOME/.config/athenactl/config.json" <<EOF
{
  "compose_file": "docker-compose.yml",
  "default_stack_root": "${ATHENA_STACK_ROOT}",
  "athena_work_remote": "${ATHENAWORK_REMOTE}",
  "athena_docs_ref": "main",
  "harness_docs_path": "${HOME}/.cache/athenactl/athenawork-docs",
  "profiles": {
    "research": {
      "model_id": "meta-llama/Meta-Llama-3.1-8B-Instruct",
      "gpu_memory_utilization": "0.90",
      "cpu_offload_gb": "0",
      "max_model_len": "4096",
      "max_num_seqs": "1",
      "extra_environment": null
    },
    "coder": {
      "model_id": "Qwen/Qwen2.5-Coder-14B-Instruct",
      "gpu_memory_utilization": "0.88",
      "cpu_offload_gb": "8",
      "max_model_len": "4096",
      "max_num_seqs": "1",
      "extra_environment": null
    },
    "chat": {
      "model_id": "meta-llama/Meta-Llama-3.1-8B-Instruct",
      "gpu_memory_utilization": "0.92",
      "cpu_offload_gb": "0",
      "max_model_len": "8192",
      "max_num_seqs": "2",
      "extra_environment": null
    }
  },
  "global_environment": {
    "NVIDIA_VISIBLE_DEVICES": "all",
    "NVIDIA_DRIVER_CAPABILITIES": "compute,utility",
    "ENABLE_OPENAI_API": "true",
    "OPENAI_API_KEY": "dummy"
  }
}
EOF
  printf 'wrote %s\n' "$HOME/.config/athenactl/config.json"
}

install_base_packages() {
  sudo apt-get update
  sudo apt-get install -y \
    ca-certificates \
    curl \
    git \
    gnupg \
    nodejs \
    npm \
    podman \
    podman-compose \
    python3
}

install_nvidia_toolkit() {
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
  curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y nvidia-container-toolkit
  sudo mkdir -p /etc/cdi
  sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
}

main() {
  require_file "$TOOLING_ROOT/dotfiles/claude/code/permissions-baseline.json"
  require_file "$TOOLING_ROOT/dotfiles/claude/code/permissions-linux-bootstrap.json"
  require_file "$TOOLING_ROOT/dotfiles/zed/settings.json"

  install_base_packages

  git config --global user.name "$GIT_USER_NAME"
  git config --global user.email "$GIT_USER_EMAIL"

  case "$CLAUDE_PROFILE" in
    baseline)
      link_config \
        "$TOOLING_ROOT/dotfiles/claude/code/permissions-baseline.json" \
        "$HOME/.claude/settings.json"
      ;;
    linux-bootstrap)
      link_config \
        "$TOOLING_ROOT/dotfiles/claude/code/permissions-linux-bootstrap.json" \
        "$HOME/.claude/settings.json"
      ;;
    *)
      echo "unsupported CLAUDE_PROFILE: $CLAUDE_PROFILE" >&2
      exit 1
      ;;
  esac

  link_config \
    "$TOOLING_ROOT/dotfiles/zed/settings.json" \
    "$HOME/.config/zed/settings.json"

  mkdir -p "$ATHENA_STACK_ROOT"
  write_athenactl_config

  if [[ "$INSTALL_NVIDIA_TOOLKIT" == "1" ]]; then
    install_nvidia_toolkit
  else
    echo "skipping NVIDIA Container Toolkit install; set INSTALL_NVIDIA_TOOLKIT=1 to enable it"
  fi

  cat <<EOF

bootstrap complete

next:
  1. clone AthenaWork into ~/Workspace/repos/trusted/AthenaWork
  2. clone athenactl into ~/Workspace/repos/trusted/athenactl
  3. ensure ~/Workspace/repos/trusted/athena-stack/docker-compose.yml exists
  4. build athenactl and run:
     ./bin/athenactl doctor
     ./bin/athenactl stack status
EOF
}

main "$@"
