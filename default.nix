{
  pkgs' ? import <nixpkgs> {}
}:

let
  pkgs = if builtins.currentSystem == "aarch64-linux"
    then pkgs'
    else pkgs'.pkgsCross.aarch64-multiplatform
  ;

  inherit (pkgs) callPackage;
in
{
  u-boot = callPackage ./u-boot {};
}
