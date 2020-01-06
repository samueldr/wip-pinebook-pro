{ config, pkgs, lib, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
    <nixpkgs/nixos/modules/profiles/minimal.nix>
    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
  ];

  nixpkgs.crossSystem = {
    system = "aarch64-linux";
  };

  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];

  boot.kernelPackages = pkgs.linuxPackages_pinebookpro;
}
