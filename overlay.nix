final: super:

let
  inherit (final) callPackage kernelPatches linuxPackagesFor;
in
{
  # Alternative BSP u-boot, with nvme support if desired
  #   * https://gitlab.manjaro.org/manjaro-arm/packages/core/uboot-pinebookpro
  uBootPinebookPro = callPackage ./u-boot {};
  uBootPinebookProExternalFirst = callPackage ./u-boot {
    externalFirst = true;
  };
  linux_pinebookpro = callPackage ./kernel {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      #kernelPatches.export_kernel_fpu_functions
      {
        name = "pinebookpro-config-fixes";
        patch = null;
        extraConfig = ''
          PCIE_ROCKCHIP y
          PCIE_ROCKCHIP_HOST y
          PCIE_DW_PLAT y
          PCIE_DW_PLAT_HOST y
          PHY_ROCKCHIP_PCIE y
          PHY_ROCKCHIP_INNO_HDMI y
          PHY_ROCKCHIP_DP y
          ROCKCHIP_MBOX y
          STAGING_MEDIA y
          VIDEO_HANTRO y
          VIDEO_HANTRO_ROCKCHIP y
          USB_DWC2_PCI y
          ROCKCHIP_LVDS y
          ROCKCHIP_RGB y
        '';
      }
    ];
  };
  linuxPackages_pinebookpro = linuxPackagesFor final.linux_pinebookpro;
  pinebookpro-firmware = callPackage ./firmware {};
  pinebookpro-keyboard-updater = callPackage ./keyboard-updater {};
}
