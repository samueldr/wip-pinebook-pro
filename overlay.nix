final: super:

let
  inherit (final) callPackage;
in
{
  # Alternative BSP u-boot, with nvme support if desired
  #   * https://gitlab.manjaro.org/manjaro-arm/packages/core/uboot-pinebookpro
  u-boot-pinebookpro = callPackage ./u-boot {};
}
