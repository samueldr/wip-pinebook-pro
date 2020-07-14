{ stdenv
, lib
, kernelPatches
, buildPackages
, fetchFromGitLab
, perl
, buildLinux
, modDirVersionArg ? null
, ... } @ args:

let
  inherit (stdenv.lib)
    concatStrings
    intersperse
    take
    splitString
    optionalString
  ;
  version = "5.6";
  additionalConfig = {
    name = "pinebookpro-config-fixes";
    patch = null;
    extraConfig = ''
      PCIE_ROCKCHIP y
      PCIE_ROCKCHIP_HOST y
      PCIE_DW_PLAT y
      PCIE_DW_PLAT_HOST y
      PHY_ROCKCHIP_PCIE y
      PHY_ROCKCHIP_INNO_HDMI y
      PHY_ROCKCHIP_DP y
      ROCKCHIP_MBOX y
      STAGING_MEDIA y
      VIDEO_HANTRO y
      VIDEO_HANTRO_ROCKCHIP y
      USB_DWC2_PCI y
      ROCKCHIP_LVDS y
      ROCKCHIP_RGB y
    '';
  };
in

buildLinux (args // {
  inherit version;

  kernelPatches = kernelPatches ++ [
    additionalConfig
  ];

  # modDirVersion needs to be x.y.z, will automatically add .0 if needed
  modDirVersion = if (modDirVersionArg == null) then concatStrings (intersperse "." (take 3 (splitString "." "${version}.0"))) else modDirVersionArg;

  # branchVersion needs to be x.y
  extraMeta.branch = concatStrings (intersperse "." (take 2 (splitString "." version)));

  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "linux-pinebook-pro";
    rev = "93293259039d6fc3a725961d42b4f11bfc3f5127";
    sha256 = "0yrn22j10f3f6hxmbd23ccis35f9s8cbjvzxiyxnsch2zab9349s";
  };

  postInstall = (optionalString (args ? postInstall) args.postInstall) + ''
    mkdir -p "$out/nix-support"
    cp -v "$buildRoot/.config" "$out/nix-support/build.config"
  '';
} // (args.argsOverride or {}))
