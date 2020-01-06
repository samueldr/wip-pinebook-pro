import <nixpkgs/nixos> {
  configuration =
    if builtins.currentSystem == "aarch64-linux"
    then builtins.toPath (./. + "/configuration.nix")
    else builtins.toPath (./. + "/with-cross.nix")
  ;
}
