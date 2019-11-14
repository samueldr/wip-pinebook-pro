{
  pkgs ? import <nixpkgs> {}
}:

let
  inherit (pkgs.pkgsCross.aarch64-multiplatform) callPackage;
in
{
  u-boot = callPackage ./u-boot.nix {};
}
