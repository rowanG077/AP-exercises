with import <nixpkgs> {};
let
  sacVCs = {
    version = "1.3.3";
    vname = "MijasCosta";
    changes = "572";
    rev = "1";
    commit = "g9eca";
  };
  libxcrypt = pkgs.callPackage ./sac2c/libxcrypt.nix { };
  sacStdLib = callPackage ./sac2c/stdlib.nix { inherit sacVCs; };
  sac2c = pkgs.callPackage ./sac2c/sac2c.nix { inherit sacStdLib sacVCs libxcrypt; };
in pkgs.mkShell {
  buildInputs = [
    sac2c
  ];
}
