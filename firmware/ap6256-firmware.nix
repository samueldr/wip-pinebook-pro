{ lib
, fetchFromGitLab
, fetchurl
, runCommandNoCC
}:

let
  manjaroArm = file: sha256: let rev = "7074a2e21dd804e229eab1c031bc00246e9173e0"; in fetchurl {
    url = "https://gitlab.manjaro.org/manjaro-arm/packages/community/ap6256-firmware/-/raw/${rev}/${file}";
    inherit sha256;
  };
in
runCommandNoCC "pinebookpro-ap6256-firmware" {
  meta = with lib; {
    license = licenses.unfreeRedistributable;
  };
} ''
  (PS4=" $ "; set -x

  cp ${(manjaroArm "BCM4345C5.hcd"               "1vl3gkgdqdlhyg9dyflqi6icglr2pll6zr82147g69pfvp6ckv96")} "BCM4345C5.hcd"
  cp ${(manjaroArm "fw_bcm43456c5_ag.bin"        "03qqgzjz152zaj9y0ppqqsqs03yzi8sb71rfvr29zc1xg1x74y3r")} "fw_bcm43456c5_ag.bin"
  cp ${(manjaroArm "brcmfmac43456-sdio.clm_blob" "0bi5y3qkqx95c6bb872slw0kig14c453r33j14qyb2f7id8m08lf")} "brcmfmac43456-sdio.clm_blob"
  cp ${(manjaroArm "nvram_ap6256.txt"            "1zsnswiiwx50pbwl8574xa7z07v9iyfajxccbfrnc8ap99gzpvj3")} "nvram_ap6256.txt"

  mkdir -p $out/lib/firmware/brcm

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
