{ stdenv
, fetchFromGitLab
}:

stdenv.mkDerivation {
  pname = "pinebookpro-firmware";
  version = "2019-12-04";

  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "pinebook-firmware";
    rev = "937f0d52d27d7712da6a008d35fd7c2819e2b077";
    sha256 = "0qldxxlxk6f3gymkljphwy7dz3cl1gxsnijhng2l7rkrh7h6wgi2";
  };

  installPhase = ''
    mkdir -p $out/lib/firmware/
    cp -rv brcm $out/lib/firmware/brcm
    cp -rv rockchip $out/lib/firmware/rockchip
  '';

  meta = with stdenv.lib; {
    license = licenses.unfreeRedistributable;
  };
}
