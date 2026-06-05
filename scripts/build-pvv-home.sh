#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash nix nix-output-monitor

set -euo pipefail

declare -r HOME=/home/pvv/d/oysteikt

declare -r NIX_DIR="${HOME}/.local/nix"
declare -r NIX_STORE="${NIX_DIR}/store"
declare -r NIX_STATE="${NIX_DIR}/var/nix"
declare -r NIX_LOG="${NIX_DIR}/var/log"
declare -r NIX_STORE="local?store=${NIX_STORE}&state=${NIX_STATE}&log=${NIX_LOG}"

# ulimit -n 1000000
# export TMPDIR="${HOME}/.cache/nix/build-dir"

# nix build --store "local?store=${NIX_STORE}&state=${NIX_STATE}&log=${NIX_LOG}" .#pkgs.binutils -L

# for i in $(seq 1 100); do
#   nix build --store "local?store=${NIX_STORE}&state=${NIX_STATE}&log=${NIX_LOG}" .#homeConfigurations.pvv.activationPackage -L --impure --keep-going
# done

NIX_ARGS=(
  -L
  --impure
  --store "$NIX_STORE"
  --option substitute false
  --builders 'nix-builder-wenche ; nix-builder-gluttony'
	# --keep-going
)

# for i in $(seq 1 100); do
nix build "${NIX_ARGS[@]}" .#homeConfigurations.pvv.activationPackage
# done

# nom build --store "local?store=${NIX_STORE}&state=${NIX_STATE}&log=${NIX_LOG}" .#homeConfigurations.pvv.activationPackage --impure
# nom build --store "local?store=${NIX_STORE}&state=${NIX_STATE}&log=${NIX_LOG}" .#homeConfigurations.pvv.activationPackage --impure
