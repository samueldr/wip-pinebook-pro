# This configuration file can be safely imported in your system configuration.
{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];

  boot.kernelPackages = pkgs.linuxPackages_pinebookpro;

  # This list of modules is not entirely minified, but represents
  # a set of modules that is required for the display to work in stage-1.
  # Further minification can be done, but requires trial-and-error mainly.
  boot.initrd.kernelModules = [
    # Rockchip modules
    "rockchip_rga"
    "rockchip_saradc"
    "rockchip_thermal"
    "rockchipdrm"

    # GPU/Display modules
    "analogix_dp"
    "cec"
    "drm"
    "drm_kms_helper"
    "dw_hdmi"
    "dw_mipi_dsi"
    "gpu_sched"
    "panel_simple"
    "panfrost"
    "pwm_bl"

    # USB / Type-C related modules
    "fusb302"
    "tcpm"
    "typec"

    # Misc. modules
    "cw2015_battery"
    "gpio_charger"
    "rtc_rk808"
  ];

  # https://gitlab.manjaro.org/manjaro-arm/packages/community/pinebookpro-post-install/blob/master/10-usb-kbd.hwdb
  services.udev.extraHwdb = ''
    evdev:input:b0003v258Ap001E*
      KEYBOARD_KEY_700a5=brightnessdown
      KEYBOARD_KEY_700a6=brightnessup
      KEYBOARD_KEY_70066=sleep 
  '';

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [
    pkgs.pinebookpro-firmware
  ];

  # Until suspend is fixed, this at least prevents the user from shooting
  # themselves in the foot by suspending accidentally, then forced to restart
  # the system forcibly..
  systemd.tmpfiles.rules = [
    "w /sys/power/mem_sleep - - - -  s2idle"
  ];

  # The default powersave makes the wireless connection unusable.
  networking.networkmanager.wifi.powersave = lib.mkDefault false;
}
