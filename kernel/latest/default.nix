# By design this is not "pinning" to any particular kernel version.
# This means that, by design, it may start failing once the patches don't apply.
# But, by design, this will track the kernel upgrades in Nixpkgs.
{ pkgs, lib, linux_latest, kernelPatches, fetchpatch, ... } @ args:

let
  nhp = patch: sha256: let rev = "dc1ddf068c11edc5149e2c36f27d5d1dd5381426"; in {
    name = patch;
    patch = (fetchpatch {
      url = "https://raw.githubusercontent.com/nadiaholmquist/pbp-packages/${rev}/linux-pbp/${patch}";
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
    # https://github.com/nadiaholmquist/pbp-packages/tree/master/linux-pbp
    (nhp "0007-mmc-core-pwrseq_simple-disable-mmc-power-on-shutdown.patch"         "1d16gjgds670dzpkb8jjlymcpp1inab3mlzbpfdinrgvfy4pywhi")
    (nhp "0011-typec-displayport-some-devices-have-pin-assignments-reversed.patch" "02dbkjkr4x407cysr9b0ps34izhq7p3gk9q7rz5abmazgcz62y4g")
    (nhp "0012-usb-typec-tcpm-Add-generic-extcon-for-tcpm-enabled-devices.patch"   "1icfy8vmwm0f825bgndhmdiskrryzpsbnrfhgvpbxwjrvwmkvlar")
    (nhp "0013-usb-typec-tcpm-Add-generic-extcon-to-tcpm.patch"                    "0qr1jv7gbdbvhxwc0lb7lfq9rvwggn0jqqcfy05y9i01nli6mxxm")
    (nhp "0014-arm64-rockchip-add-DP-ALT-rockpro64.patch"                          "03k13jgcnz7wmks1y1fgzpjj2yvi114cbvprmnkyf8xrjns7x5q0")
    (nhp "0015-ayufan-drm-rockchip-add-support-for-modeline-32MHz-e.patch"         "0z51whv0bjj45l5z3q4v0rqdvz62dh4qg8ccd87la9ga8y1v14cy")
    (nhp "0021-usb-typec-bus-Catch-crash-due-to-partner-NULL-value.patch"          "0a4zd7ihd9pj6djgcj4ayaw7ff0xs9wqgmcvhwchwy766js3l5rp")
    (nhp "0022-phy-rockchip-typec-Set-extcon-capabilities.patch"                   "0pqq856g0yndxvg9ipbx1jv6j4ldvapgzvxzvpirygc7f0wdrz49")
    (nhp "0023-usb-typec-altmodes-displayport-Add-hacky-generic-altmode.patch"     "1vldwg3zwrx2ppqgbhc91l48nfmjkmwwdsyq6mq6f3l1cwfdn62q")
    (nhp "0024-arm64-dts-rockchip-setup-USB-type-c-port-as-dual-dat.patch"         "0zwwyhryghafga36mgnazn6gk88m2rvs8ng5ykk4hhg9pi5bgzh9")
    (nhp "0026-arm64-dts-rockchip-add-typec-extcon-hack.patch"                     "1kri47nkm6qgsqgkxzgy6iwhpajcx9xwd4rf8dldr6prb9f6iv3p")
    (nhp "pbp-2d-fix.patch"                                                        "1hwd6clk1qnjyd4jl7kjn9pnilijz4brh1p5dnv8jzr2ajx2346j")
  ]);
})
//
(args.argsOverride or {})
