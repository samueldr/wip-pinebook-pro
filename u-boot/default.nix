{ buildUBoot
, lib
, python
, armTrustedFirmwareRK3399
, fetchpatch
, fetchFromGitLab
, fetchFromGitHub
, externalFirst ? false
, runCommandNoCC
}:

let
  pw = id: sha256: fetchpatch {
    inherit sha256;
    name = "${id}.patch";
    url = "https://patchwork.ozlabs.org/patch/${id}/raw/";
  };

  # The version number for our opinionated firmware.
  firmwareVersion = "002";

  logo = runCommandNoCC "pbp-logo" {} ''
    mkdir -p $out
    cp ${../artwork/nixos+pine-rle.bmp} $out/logo.bmp                         
    (cd $out; gzip -k logo.bmp)                           
  '';                                    

  atf = armTrustedFirmwareRK3399.overrideAttrs(oldAttrs: {
    src = fetchFromGitHub {
      owner = "ARM-software";
      repo = "arm-trusted-firmware";
      rev = "9935047b2086faa3bf3ccf0b95a76510eb5a160b";
      sha256 = "1a6pm0nbgm5r3a41nwlkrli90l2blcijb02li7h75xcri6rb7frk";
    };
    version = "2020-06-17";
  });
in
(buildUBoot {
  defconfig = "pinebook-pro-rk3399_defconfig";
  extraMeta.platforms = ["aarch64-linux"];
  BL31 = "${atf}/bl31.elf";
  filesToInstall = [
    "idbloader.img"
    "u-boot.itb"
    ".config"
  ];

  extraPatches = [
    # Upstream upcoming patches
    # -------------------------
    #
    # https://patchwork.ozlabs.org/project/uboot/list/?series=182073
    #
    # RNG
    # https://patchwork.ozlabs.org/patch/1305440/
    (pw "1305440" "1w4vvj3la34rsdf5snlvjl9yxnxrybczjz8m73891x1r6lvr1agk")
    # USB
    # https://patchwork.ozlabs.org/patch/1305441/
    (pw "1305441" "1my6vz2j7dp6k9qdyf4kzyfy2fgvj4bhxq0xnjkdvsasiz7rq2x9")
    # SPI has been skipped as it seemed to cause issues.

    # Upcoming patches
    # ----------------
    #
    # These are not yet available on Patchwork. They are of *beta* quality.
    # http://people.hupstream.com/~rtp/pbp/20200706/patches/series
    #
    # I have been authorised to distribute.
    #
    ./0001-display-support.patch

    # Dhivael patchset
    # ----------------
    #
    # Origin: https://git.eno.space/pbp-uboot.git/
    # Forward ported to 2020.07

    ./0001-rk3399-light-pinebook-power-and-standby-leds-during-.patch
    ./0002-reduce-pinebook_pro-bootdelay-to-1.patch
    ./0005-support-SPI-flash-boot.patch

    # samueldr's patchset
    # -------------------
    ./0001-opinionated-boot.patch
  ] ++ lib.optionals (externalFirst) [
    # Origin: https://git.eno.space/pbp-uboot.git/
    # Forward ported to 2020.07
    ./0003-rockchip-move-mmc1-before-mmc0-in-default-boot-order.patch
    ./0004-rockchip-move-usb0-after-mmc1-in-default-boot-order.patch
  ];
      
  extraConfig = ''                                                                
    CONFIG_IDENT_STRING=" (samueldr-pbp) v${firmwareVersion}"
  '';             
})
.overrideAttrs(oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
    python
  ];

  postPatch = oldAttrs.postPatch + ''
    patchShebangs arch/arm/mach-rockchip/
  '';

  postInstall = ''
    tools/mkimage -n rk3399 -T rkspi -d tpl/u-boot-tpl-dtb.bin:spl/u-boot-spl-dtb.bin spl.bin
    cat <(dd if=spl.bin bs=512K conv=sync) u-boot.itb > $out/u-boot.spiflash.bin
  '';

  makeFlags = oldAttrs.makeFlags ++ [
    "LOGO_BMP=${logo}/logo.bmp"
  ];

  src = fetchFromGitLab {
    domain = "gitlab.denx.de";
    owner = "u-boot";
    repo = "u-boot";
    sha256 = "11154cxycw81dnmxfl10n2mgyass18jhjpwygqp7w1vjk9hgi4lw";
    rev = "v2020.07";
  };
})
