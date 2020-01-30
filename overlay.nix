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
  kernelPatches = super.kernelPatches // {
    rockchip-sip = {
      name = "rockchip-sip";
      patch = ./kernel/0001-firmware-rockchip-sip-add-rockchip-SIP-runtime-servi.patch;
    };
    rk3399-suspend = {
      name = "rk3399-suspend";
      patch = ./kernel/0002-suspend-rockchip-set-the-suspend-config-to-ATF.patch;
    };
    pbp-suspend-config = {
      name = "pbp-suspend-config";
      patch = ./kernel/0003-Configure-suspend-for-rk3399.patch;
    };
    rockchip-virtpoweroff = {
      name = "rockchip-virtpoweroff";
      patch = ./kernel/0004-soc-rockchip-add-virtual-poweroff-support.patch;
    };
    rockchip-update-sip = {
      name = "rockchip-update-sip";
      patch = ./kernel/0005-firmware-rockchip-update-sip-interface.patch;
    };
  };
  linux_pinebookpro = callPackage ./kernel {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      #kernelPatches.export_kernel_fpu_functions
      kernelPatches.rockchip-sip
      kernelPatches.rk3399-suspend
      kernelPatches.pbp-suspend-config
      kernelPatches.rockchip-virtpoweroff
      kernelPatches.rockchip-update-sip
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
