{ lib
, fetchFromGitLab
, fetchurl
, runCommandNoCC
}:

let
  nhp = patch: sha256: let rev = "c74b23b8766e4cfc50d1197e6dcd08cc1625866f"; in fetchurl {
    url = "https://raw.githubusercontent.com/nadiaholmquist/pbp-packages/${rev}/ap6256-firmware/${patch}";
    inherit sha256;
  };
in
runCommandNoCC "pinebookpro-ap6256-firmware" {
  meta = with lib; {
    license = licenses.unfreeRedistributable;
  };
} ''
  (PS4=" $ "; set -x

  cp ${(nhp "BCM4345C5.hcd"               "1vl3gkgdqdlhyg9dyflqi6icglr2pll6zr82147g69pfvp6ckv96")} "BCM4345C5.hcd"
  cp ${(nhp "fw_bcm43456c5_ag.bin"        "03qqgzjz152zaj9y0ppqqsqs03yzi8sb71rfvr29zc1xg1x74y3r")} "fw_bcm43456c5_ag.bin"
  cp ${(nhp "brcmfmac43456-sdio.clm_blob" "0bi5y3qkqx95c6bb872slw0kig14c453r33j14qyb2f7id8m08lf")} "brcmfmac43456-sdio.clm_blob"
  cp ${(nhp "nvram_ap6256.txt"            "1zsnswiiwx50pbwl8574xa7z07v9iyfajxccbfrnc8ap99gzpvj3")} "nvram_ap6256.txt"

  mkdir -p $out/lib/firmware/brcm

  # https://github.com/nadiaholmquist/pbp-packages/blob/ded66e50064c55a56a958558ab35bc6bae444e72/ap6256-firmware/PKGBUILD#L22
  # Bluetooth firmware
  install -Dm644 "BCM4345C5.hcd" -t "$out/lib/firmware/"
  install -Dm644 "BCM4345C5.hcd"    "$out/lib/firmware/brcm/BCM.hcd"
  install -Dm644 "BCM4345C5.hcd" -t "$out/lib/firmware/brcm/"
  # Wifi firmware
  install -Dm644 "nvram_ap6256.txt" -t         "$out/lib/firmware/"
  install -Dm644 "fw_bcm43456c5_ag.bin"        "$out/lib/firmware/brcm/brcmfmac43456-sdio.bin"
  install -Dm644 "brcmfmac43456-sdio.clm_blob" "$out/lib/firmware/brcm/brcmfmac43456-sdio.clm_blob"
  install -Dm644 "nvram_ap6256.txt"            "$out/lib/firmware/brcm/brcmfmac43456-sdio.radxa,rockpi4b.txt"
  install -Dm644 "nvram_ap6256.txt"            "$out/lib/firmware/brcm/brcmfmac43456-sdio.radxa,rockpi4c.txt"
  install -Dm644 "nvram_ap6256.txt"            "$out/lib/firmware/brcm/brcmfmac43456-sdio.pine64,pinebook-pro.txt"
  install -Dm644 "nvram_ap6256.txt"            "$out/lib/firmware/brcm/brcmfmac43456-sdio.pine64,rockpro64-v2.1.txt"
  )
''
