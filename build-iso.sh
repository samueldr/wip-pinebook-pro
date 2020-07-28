#!/usr/bin/env bash

set -e
set -u
PS4=" $ "

# Ugh, I would have liked to do it through a simpler `nix-build`, but  as this
# needs to set `NIX_PATH` for use of `<nixpkgs/*>` imports, this is the better
# way to go.

set -x
exec env -i \
	NIXPKGS_ALLOW_UNFREE=1 \
	NIX_PATH="nixpkgs=channel:nixos-unstable" \
	"$(command -v nix-build)" \
	iso.nix -A config.system.build.isoImage "$@"
