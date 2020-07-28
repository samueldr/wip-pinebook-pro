import <nixpkgs/nixos> {
  configuration = {
    imports = [
      (
        if builtins.currentSystem == "aarch64-linux"
        then builtins.toPath (./. + "/configuration.nix")
        else builtins.toPath (./. + "/with-cross.nix")
        )
        <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
      ];
    };
  }
