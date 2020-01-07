{ stdenv, fetchFromGitHub, xxd, libusb }:

stdenv.mkDerivation {
  pname = "pinebook-pro-keyboard-updater";
  version = "2019-11-24";

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
    rev = "e2192c37456c6c3d0701ead62d56c320f80858b9";
    sha256 = "1pwz2fdqlwvab3xswi97msn06znbzdlbx1j4qx8fmqkqfg8z260z";
  };
}
