{
  description = "WIP stuff to get started on the pinebook pro.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs-channels/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlay = final: prev: import "${self}/overlay.nix" final prev;
    } // flake-utils.lib.eachDefaultSystem (
      system:
        let
          darwin_network_cmds_openssl_overlay = final: prev: {
            darwin = prev.darwin // {
              network_cmds = prev.darwin.network_cmds.override { openssl_1_0_2 = prev.openssl; };
            };
          };
          pkgsNative = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ darwin_network_cmds_openssl_overlay self.overlay ];
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

            nixosConfigurations = nixpkgs.lib.nixosSystem {
              system = "aarch64-linux";
              # Pass nixpkgs as an argument to each module so that modules from nixpkgs can be imported purely
              specialArgs = { inherit nixpkgs; };
              modules = [
                { nixpkgs.config.allowUnfree = true; }
                (if system == "aarch64-linux" then "${self}/configuration.nix" else "${self}/with-cross.nix")
              ];
            };

            nixosModule = import "${self}/pinebook_pro.nix";
          }
    );
}
