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
    version = "5.4.0";

    # modDirVersion needs to be x.y.z, will automatically add .0 if needed
    modDirVersion = if (modDirVersionArg == null) then concatStrings (intersperse "." (take 3 (splitString "." "${version}.0"))) else modDirVersionArg;

    # branchVersion needs to be x.y
    extraMeta.branch = concatStrings (intersperse "." (take 2 (splitString "." version)));

    src = fetchFromGitLab {
      domain = "gitlab.manjaro.org";
      owner = "tsys";
      repo = "linux-pinebook-pro";
      rev = "877ca0e7283596f37845de50dc36bff5b88b91e1";
      sha256 = "1g1ysnd25d5b8rv437n6cbjb9496aj2ljzk7zkqgdjllk66yipl4";
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
