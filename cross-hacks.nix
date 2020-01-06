# From this upstream repo:
# https://github.com/samueldr/cross-system
{ config, pkgs, lib, ... }:
{

  nixpkgs.overlays = [
    (self: super: {
      # Does not cross-compile...
      alsa-firmware = pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";
    })
  ];

  # (Failing build in a dep to be investigated)
  security.polkit.enable = false;

  # cifs-utils fails to cross-compile
  # Let's simplify this by removing all unneeded filesystems from the image.
  boot.supportedFilesystems = lib.mkForce [ "vfat" ];

  # texinfoInteractive has trouble cross-compiling
  documentation.info.enable = lib.mkForce false;

  # `xterm` is being included even though this is GUI-less.
  # → https://github.com/NixOS/nixpkgs/pull/62852
  services.xserver.desktopManager.xterm.enable = lib.mkForce false;
}
