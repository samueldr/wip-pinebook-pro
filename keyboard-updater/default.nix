{ stdenv, fetchFromGitHub, xxd, libusb }:

stdenv.mkDerivation {
  pname = "pinebook-pro-keyboard-updater";
  version = "2020-01-22";

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
    owner = "jackhumbert";
    repo = "pinebook-pro-keyboard-updater";
    rev = "10535c84ee599d3225b02a391c6eb2f9d8d5cdbe";
    sha256 = "1kk4qzliqn1r8vfx8zdfpkpqazhxr4v2baahhgmlsblh0cm1cxnc";
  };
}
