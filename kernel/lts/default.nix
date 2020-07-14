{ pkgs, lib, linux_5_4, kernelPatches, ... } @ args:

linux_5_4.override({
  # The way the linux kernel is composed, kernelPatches will end up filled-in twice...
  # Not entirely sure why.
  kernelPatches = lib.lists.unique (kernelPatches ++ [
    pkgs.kernelPatches.bridge_stp_helper
    pkgs.kernelPatches.request_key_helper
    pkgs.kernelPatches.export_kernel_fpu_functions."5.3"
    {
      name = "pinebookpro-5.4-lts.patch";
      patch = ./pinebookpro-5.4-lts.patch;
    }
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
        VIDEO_HANTRO m
        VIDEO_HANTRO_ROCKCHIP y
        USB_DWC2_PCI y
        ROCKCHIP_LVDS y
        ROCKCHIP_RGB y
      '';
    }
  ]);
})
//
(args.argsOverride or {})
