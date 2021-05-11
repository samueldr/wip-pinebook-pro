final: super:

let
  inherit (final) callPackage kernelPatches linuxPackagesFor;
in
{
  # The unqualified kernel attr is deprecated.
  linux_pinebookpro = throw "The linux_pinebookpro attribute has been replaced by linux_pinebookpro_latest.";
  linuxPackages_pinebookpro = throw "The linuxPackages_pinebookpro attribute has been replaced by linuxPackages_pinebookpro_latest.";

  linux_pinebookpro_latest = callPackage ./kernel/latest { kernelPatches = []; };
  linuxPackages_pinebookpro_latest = linuxPackagesFor final.linux_pinebookpro_latest;

  linux_pinebookpro_lts = callPackage ./kernel/lts { kernelPatches = []; };
  linuxPackages_pinebookpro_lts = linuxPackagesFor final.linux_pinebookpro_lts;

  pinebookpro-ap6256-firmware = callPackage ./firmware/ap6256-firmware.nix {};
  pinebookpro-keyboard-updater = callPackage ./keyboard-updater {};
}
