{ stdenv
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
in
(
  buildLinux (args // rec {
    version = "5.5.0";

    # modDirVersion needs to be x.y.z, will automatically add .0 if needed
    modDirVersion = if (modDirVersionArg == null) then concatStrings (intersperse "." (take 3 (splitString "." "${version}.0"))) else modDirVersionArg;

    # branchVersion needs to be x.y
    extraMeta.branch = concatStrings (intersperse "." (take 2 (splitString "." version)));

    src = fetchFromGitLab {
      domain = "gitlab.manjaro.org";
      owner = "tsys";
      repo = "linux-pinebook-pro";
      rev = "799b9141e48783a0844187ad00855b3d53f77998";
      sha256 = "1h75m5mb69hl0dqb1w5qrn6dzaak4dx7b2dxkk9d3990i796hrfs";
    };

    postInstall = (optionalString (args ? postInstall) args.postInstall) + ''
      mkdir -p "$out/nix-support"
      cp -v "$buildRoot/.config" "$out/nix-support/build.config"
    '';
  } // (args.argsOverride or {}))
)
#).overrideAttrs(args: {
#  postInstall = (optionalString (args ? postInstall) args.postInstall) + ''
#    mkdir -p "$out/nix-support"
#    cp -v "$buildRoot/.config" "$out/nix-support/build.config"
#  '';
#})
