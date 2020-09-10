{
  description = "WIP stuff to get started on the pinebook pro.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs-channels/nixos-20.09";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlay = final: prev: import "${self}/overlay.nix" final prev;
      nixosModule = import "${self}/pinebook_pro.nix";
    } // flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (
      system:
        let
          inherit (nixpkgs) lib;
          pkgsNative = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlay ];
          };
          pkgs = if system == "aarch64-linux" then pkgsNative else pkgsNative.pkgsCross.aarch64-multiplatform;
        in
          rec {
            packages = rec {
              inherit (pkgs)
                uBootPinebookPro uBootPinebookProExternalFirst
                linux_pinebookpro_latest
                linux_pinebookpro_lts
                pinebookpro-firmware
                pinebookpro-keyboard-updater
                ;

              inherit (nixosConfigurations.config.system.build) sdImage;
            };

            defaultPackage = packages.sdImage;

            nixosConfigurations = lib.nixosSystem {
              system = "aarch64-linux";
              # Pass nixpkgs as an argument to each module so that modules from nixpkgs can be imported purely
              specialArgs = { inherit nixpkgs; };
              modules = [
                { nixpkgs.config.allowUnfree = true; }
                "${self}/configuration.nix"
                (
                  lib.optionalAttrs (system != "aarch64-linux") {
                    imports = [ "${self}/cross-hacks.nix" ];
                    nixpkgs.crossSystem.system = "aarch64-linux";
                  }
                )
              ];
            };
          }
    );
}
