final: super:

let
  inherit (final) callPackage kernelPatches linuxPackagesFor;
in
{
  linuxPackages_pinebookpro_latest = throw "Use the mainline kernel directly instead (linuxPackages_latest).";
  linux_pinebookpro_latest = throw "Use the mainline kernel directly instead (linuxPackages_latest).";

  linuxPackages_pinebookpro_lts = throw "Use the mainline kernel directly instead (linuxPackages_latest).";
  linux_pinebookpro_lts = throw "Use the mainline kernel directly instead (linuxPackages_latest).";

  pinebookpro-ap6256-firmware = callPackage ./firmware/ap6256-firmware.nix {};
  pinebookpro-keyboard-updater = callPackage ./keyboard-updater {};
}
