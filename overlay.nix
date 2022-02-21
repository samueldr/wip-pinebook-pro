final: super:

let
  inherit (final) callPackage kernelPatches linuxPackagesFor;
in
{
  # The unqualified kernel attr is deprecated.
  linuxPackages_pinebookpro_latest = throw "Use the mainline kernel directly instead (linuxPackages_latest).";
  linux_pinebookpro_latest = throw "Use the mainline kernel directly instead (linuxPackages_latest).";

  linux_pinebookpro_lts = callPackage ./kernel/lts { kernelPatches = []; };
  linuxPackages_pinebookpro_lts = linuxPackagesFor final.linux_pinebookpro_lts;

  pinebookpro-ap6256-firmware = callPackage ./firmware/ap6256-firmware.nix {};
  pinebookpro-keyboard-updater = callPackage ./keyboard-updater {};
}
