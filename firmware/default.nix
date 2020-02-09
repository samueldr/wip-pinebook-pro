{ stdenv
, fetchFromGitLab
, runCommandNoCC
}:

let
  pinebook-firmware = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "pinebook-firmware";
    rev = "937f0d52d27d7712da6a008d35fd7c2819e2b077";
    sha256 = "0qldxxlxk6f3gymkljphwy7dz3cl1gxsnijhng2l7rkrh7h6wgi2";
  };
  ap6256-firmware = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "manjaro-arm";
    repo = "packages%2Fcommunity%2Fap6256-firmware";
    rev = "a30bf312b268eab42d38fab0cc3ed3177895ff5d";
    sha256 = "14gyb99j85xw07wrr9lilb1jz68y6r0n0b6x4ldl7d6igs988qwb";
  };
in
runCommandNoCC "pinebookpro-firmware-2020-02-08" {
  meta = with stdenv.lib; {
    license = licenses.unfreeRedistributable;
  };
} ''
  (PS4=" $ "; set -x
  mkdir -p $out/lib/firmware/{brcm,rockchip}
  (cd ${ap6256-firmware}
  cp -fv *.hcd *blob *.bin *.txt $out/lib/firmware/brcm/
  )
  cp -fv ${pinebook-firmware}/brcm/* $out/lib/firmware/brcm/
  cp -fv ${pinebook-firmware}/rockchip/* $out/lib/firmware/rockchip/
  )
''
