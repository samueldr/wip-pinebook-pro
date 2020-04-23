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
    version = "5.6";

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
)
#).overrideAttrs(args: {
#  postInstall = (optionalString (args ? postInstall) args.postInstall) + ''
#    mkdir -p "$out/nix-support"
#    cp -v "$buildRoot/.config" "$out/nix-support/build.config"
#  '';
#})
