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
    version = "5.5.0-rc7";

    # modDirVersion needs to be x.y.z, will automatically add .0 if needed
    modDirVersion = if (modDirVersionArg == null) then concatStrings (intersperse "." (take 3 (splitString "." "${version}.0"))) else modDirVersionArg;

    # branchVersion needs to be x.y
    extraMeta.branch = concatStrings (intersperse "." (take 2 (splitString "." version)));

    src = fetchFromGitLab {
      domain = "gitlab.manjaro.org";
      owner = "tsys";
      repo = "linux-pinebook-pro";
      rev = "b3ba5b2b87e9bd191265776b93277e49d044b79e";
      sha256 = "1fj6gkpy422lw23qg0hwyv5hbfx3pfhgv67ma44ly2mxmgna4nsh";
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
