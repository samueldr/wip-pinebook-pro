{ pkgs ? import <nixpkgs> {} }:

let pkgs' = pkgs; in
let
  pkgs = if !isCross then pkgs' else pkgs'.pkgsCross.aarch64-multiplatform;
  inherit (pkgs) lib;
  isCross = builtins.currentSystem != "aarch64-linux";

  fromPkgs = path: pkgs.path + "/${path}";
  evalConfig = import (fromPkgs "nixos/lib/eval-config.nix");

  buildConfig = { system ? "aarch64-linux", configuration ? {} }:
    evalConfig {
      modules = (lib.optional isCross ./cross-hacks.nix)
      ++ [
          "${./.}/pinebook_pro.nix"
          configuration
          (lib.mkIf isCross {
            nixpkgs.crossSystem = {
              system = "aarch64-linux";
            };
          })
      ];
    }
  ;
  base = buildConfig {};
in
{
  inherit (base) pkgs;

  kernel_latest = base.pkgs.linuxPackages_pinebookpro_latest.kernel;
  kernel_lts    = base.pkgs.linuxPackages_pinebookpro_lts.kernel;

  isoImage = (buildConfig {
    configuration = (fromPkgs "nixos/modules/installer/cd-dvd/installation-cd-minimal.nix");
  }).config.system.build.isoImage;

  sdImage = (buildConfig {
    configuration = (fromPkgs "nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix");
  }).config.system.build.sdImage;
}
