{ config, pkgs, lib, ... }:
{
  imports = [
    ./cross-hacks.nix
    ./configuration.nix
  ];

  nixpkgs.crossSystem = {
    system = "aarch64-linux";
  };
}
