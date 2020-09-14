{ nixpkgs, config, pkgs, lib, ... }:

let
  uboot = pkgs.uBootPinebookProExternalFirst;
in
{
  imports = [
    "${nixpkgs}/nixos/modules/profiles/base.nix"
    "${nixpkgs}/nixos/modules/profiles/minimal.nix"
    "${nixpkgs}/nixos/modules/profiles/installation-device.nix"
    ./nixos/sd-image-aarch64.nix
    ./pinebook_pro.nix
  ];

  sdImage = {
    manipulateImageCommands = ''
      (PS4=" $ "; set -x
      dd if=${uboot}/idbloader.img of=$img bs=512 seek=64 conv=notrunc
      dd if=${uboot}/u-boot.itb of=$img bs=512 seek=16384 conv=notrunc
      )
    '';
    compressImage = lib.mkForce false;
  };
}
