final: super:

let
  inherit (final) callPackage kernelPatches linuxPackagesFor;
  renamed = old: new: builtins.trace "The ${old} attribute name is deprecated. Prefer using ${new}." final.${new};
in
{
  # Alternative BSP u-boot, with nvme support if desired
  #   * https://gitlab.manjaro.org/manjaro-arm/packages/core/uboot-pinebookpro
  ubootPinebookPro = callPackage ./u-boot {};
  ubootPinebookProExternalFirst = callPackage ./u-boot {
    externalFirst = true;
  };

  # Image to be written to SD to install to SPI.
  pinebookpro-firmware-installer = callPackage ./u-boot/spi-installer.nix {
    uboot = final.uBootPinebookPro;
  };           

  # The unqualified kernel attr is deprecated.
  linux_pinebookpro = throw "The linux_pinebookpro attribute has been replaced by linux_pinebookpro_latest.";
  linuxPackages_pinebookpro = throw "The linuxPackages_pinebookpro attribute has been replaced by linuxPackages_pinebookpro_latest.";

  linux_pinebookpro_latest = callPackage ./kernel/latest { kernelPatches = []; };
  linuxPackages_pinebookpro_latest = linuxPackagesFor final.linux_pinebookpro_latest;

  linux_pinebookpro_lts = callPackage ./kernel/lts { kernelPatches = []; };
  linuxPackages_pinebookpro_lts = linuxPackagesFor final.linux_pinebookpro_lts;

  pinebookpro-firmware = callPackage ./firmware {};
  pinebookpro-keyboard-updater = callPackage ./keyboard-updater {};

  # Aliases

  # Renamed to better follow the Nixpkgs naming scheme.
  uBootPinebookPro = renamed "uBootPinebookPro" "ubootPinebookPro";
  uBootPinebookProExternalFirst = renamed "uBootPinebookProExternalFirst" "ubootPinebookProExternalFirst";
}
