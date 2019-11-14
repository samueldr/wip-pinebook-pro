{ buildUBoot
, python
, armTrustedFirmwareRK3399
, fetchpatch
, fetchFromGitLab
, fetchFromGitHub
}:

let
  pw = id: sha256: fetchpatch {
    inherit sha256;
    name = "${id}.patch";
    url = "https://patchwork.ozlabs.org/patch/${id}/raw/";
  };

  atf = armTrustedFirmwareRK3399.overrideAttrs(oldAttrs: {
    src = fetchFromGitHub {
      owner = "ARM-software";
      repo = "arm-trusted-firmware";
      rev = "v2.2";
      sha256 = "03fjl5hy1bqlya6fg553bqz7jrvilzrzpbs87cv6jd04v8qrvry8";
    };
    version = "2.2";
  });
in
(buildUBoot {
  defconfig = "pinebook_pro-rk3399_defconfig";
  extraMeta.platforms = ["aarch64-linux"];
  BL31 = "${atf}/bl31.elf";
  filesToInstall = [
    "idbloader.img"
    "u-boot.itb"
    ".config"
  ];

  extraPatches = [
    (pw "1194523" "07l19km7vq4xrrc3llcwxwh6k1cx5lj5vmmzml1ji8abqphwfin6")
    (pw "1194524" "071rval4r683d1wxh75nbf22qs554spq8rk0499z6zac0x8q1qvc")
    (pw "1194525" "0biiwimjp25abxqazqbpxx2wh90zgy3k786h484x9wsdvnv4yjl6")
  ];
})
.overrideAttrs(oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
    python
  ];
  postPatch = oldAttrs.postPatch + ''
    patchShebangs arch/arm/mach-rockchip/
  '';

  src = fetchFromGitLab {
    domain = "gitlab.denx.de";
    owner = "u-boot";
    repo = "u-boot";
    sha256 = "1fb8135gq8md2gr9sng1q2s1wj74xhy7by16dafzp4263b6vbwyv";
    rev = "3ff1ff3ff76c15efe0451309af084ee6c096c583";
  };
})
