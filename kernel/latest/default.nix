# By design this is not "pinning" to any particular kernel version.
# This means that, by design, it may start failing once the patches don't apply.
# But, by design, this will track the kernel upgrades in Nixpkgs.
{ pkgs, lib, linux_latest, kernelPatches, fetchpatch, ... } @ args:

let
  manjaroArmPatch = patch: sha256: let rev = "551a0d0c4f8e2dce4e565187fae97ec437d6aef4"; in {
    name = patch;
    patch = (fetchpatch {
      url = "https://gitlab.manjaro.org/manjaro-arm/packages/core/linux/-/raw/${rev}/${patch}";
      inherit sha256;
    });
  };
in
linux_latest.override({
  kernelPatches = lib.lists.unique (kernelPatches ++ [
    pkgs.kernelPatches.bridge_stp_helper
    pkgs.kernelPatches.request_key_helper

    # Kernel configuration
    {
      # None of these *need* to be set to `y`.
      # But eh, it works too
      name = "pinebookpro-config";
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
        USB_DWC2_PCI y
        ROCKCHIP_LVDS y
        ROCKCHIP_RGB y
      '';
    }
    {
      name = "video-hantro-config";
      patch = null;
      extraConfig = ''
        STAGING_MEDIA y
        VIDEO_HANTRO m
        VIDEO_HANTRO_ROCKCHIP y
      '';
    }

    # Misc. community patches
    # None are *required* for basic function.
    # https://gitlab.manjaro.org/manjaro-arm/packages/core/linux
    (manjaroArmPatch "0005-drm-bridge-analogix_dp-Add-enable_psr-param.patch"                  "0a7r2fqir98125dqfy8whafmcyawvqkk8yn96596xsqzmr0ki2jv")
    (manjaroArmPatch "0009-typec-displayport-some-devices-have-pin-assignments-reversed.patch" "02dbkjkr4x407cysr9b0ps34izhq7p3gk9q7rz5abmazgcz62y4g")
    (manjaroArmPatch "0010-usb-typec-add-extcon-to-tcpm.patch"                                 "0h3p1hxc54jh7dplc21w59cksddlgz1f2yqw2nf4w0syxy4qijn3")
    (manjaroArmPatch "0011-arm64-rockchip-add-DP-ALT-rockpro64.patch"                          "03k13jgcnz7wmks1y1fgzpjj2yvi114cbvprmnkyf8xrjns7x5q0")
    (manjaroArmPatch "0012-ayufan-drm-rockchip-add-support-for-modeline-32MHz-e.patch"         "0z51whv0bjj45l5z3q4v0rqdvz62dh4qg8ccd87la9ga8y1v14cy")
    (manjaroArmPatch "0013-rk3399-rp64-pcie-Reimplement-rockchip-PCIe-bus-scan-delay.patch"    "04pgcikc18bihkdqi56l0ivza12a9wq8r40gz25y57p1is9vikp9")
    (manjaroArmPatch "0001-phy-rockchip-typec-Set-extcon-capabilities.patch"                   "0pqq856g0yndxvg9ipbx1jv6j4ldvapgzvxzvpirygc7f0wdrz49")
    (manjaroArmPatch "0002-usb-typec-altmodes-displayport-Add-hacky-generic-altmode.patch"     "1vldwg3zwrx2ppqgbhc91l48nfmjkmwwdsyq6mq6f3l1cwfdn62q")
    (manjaroArmPatch "0003-arm64-dts-rockchip-add-typec-extcon-hack.patch"                     "1kri47nkm6qgsqgkxzgy6iwhpajcx9xwd4rf8dldr6prb9f6iv3p")
    (manjaroArmPatch "0004-arm64-dts-rockchip-setup-USB-type-c-port-as-dual-data-role.patch"   "0zwwyhryghafga36mgnazn6gk88m2rvs8ng5ykk4hhg9pi5bgzh9")
  ]);
})
//
(args.argsOverride or {})
