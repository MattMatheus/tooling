# Ubuntu/Kubuntu Bootstrap

## Summary

This is the reproducible host bootstrap path for Ubuntu 24.04-family machines, including Kubuntu. It installs the base packages AthenaWork needs, links the shared config files from `tooling`, and writes the local `athenactl` config used on Linux workstations.

## Intended Audience

- a fresh Ubuntu/Kubuntu workstation setup
- a rebuild of the current Linux development machine

## Preconditions

- the OS is Ubuntu-family with `apt-get`
- this repo is already cloned locally
- `sudo` access is available

## Main Flow

Run:

```bash
cd ~/Workspace/repos/trusted/tooling
chmod +x bootstrap/ubuntu-kubuntu-dev-host.sh
./bootstrap/ubuntu-kubuntu-dev-host.sh
```

Optional NVIDIA CDI setup during bootstrap:

```bash
INSTALL_NVIDIA_TOOLKIT=1 ./bootstrap/ubuntu-kubuntu-dev-host.sh
```

Important environment overrides:

```bash
TOOLING_ROOT=~/Workspace/repos/trusted/tooling
ATHENA_STACK_ROOT=~/Workspace/repos/trusted/athena-stack
ATHENAWORK_REMOTE=git@github.com:MattMatheus/AthenaWork.git
CLAUDE_PROFILE=linux-bootstrap
```

## What It Does

- installs `git`, `nodejs`, `npm`, `python3`, `podman`, and `podman-compose`
- configures global git identity
- links Claude and Zed settings from this repo
- writes `~/.config/athenactl/config.json`
- optionally installs NVIDIA Container Toolkit and generates `/etc/cdi/nvidia.yaml`

## After Bootstrap

1. Clone `AthenaWork` to `~/Workspace/repos/trusted/AthenaWork`
2. Clone `athenactl` to `~/Workspace/repos/trusted/athenactl`
3. Ensure `~/Workspace/repos/trusted/athena-stack/docker-compose.yml` exists
4. Build `athenactl`
5. Run `./bin/athenactl doctor`

## Failure Modes

- running the script before this repo exists locally
- using it on a non-Ubuntu-family distro
- expecting it to install GUI apps such as Zed or Claude CLI
- forgetting `INSTALL_NVIDIA_TOOLKIT=1` on a GPU host that needs CDI

## References

- `bootstrap/ubuntu-kubuntu-dev-host.sh`
- `README.md`
