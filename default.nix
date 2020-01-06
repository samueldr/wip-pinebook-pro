{
  pkgs ? import (builtins.fetchTarball "channel:nixos-19.09") {
    overlays = [
      (import ./overlay.nix)
    ];
  }
}:

let
  pkgs' = if builtins.currentSystem == "aarch64-linux"
    then pkgs
    else pkgs.pkgsCross.aarch64-multiplatform
  ;
in
{
  pkgs = pkgs';
}
