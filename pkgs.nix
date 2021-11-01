let
  sha256 = "0j8pdr9ymk7a2p8pamcbq2rbhlcg923i6abdmdm6496973s5gb34";
  rev = "e544ee88fa4590df75e221e645a03fe157a99e5b";
in
builtins.trace "(Using pinned Nixpkgs at ${rev})"
import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
  inherit sha256;
})
