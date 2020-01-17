{ stdenv, fetchFromGitHub, xxd, libusb }:

stdenv.mkDerivation {
  pname = "pinebook-pro-keyboard-updater";
  version = "2020-01-14";

  nativeBuildInputs = [
    xxd
  ];

  buildInputs = [
    libusb
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -v updater $out/bin
  '';

  src = fetchFromGitHub {
    owner = "ayufan-rock64";
    repo = "pinebook-pro-keyboard-updater";
    rev = "68c5232b75a2acd8aa3e2c8b623b01a5465dca72";
    sha256 = "013mqdxhgszv7syss9lsxjxq00yxy7idj9k2ib1yq2wf0y7kvx96";
  };
}
