with ((import (fetchTarball {
  name = "nixpkgs-master-2021-04-09";
  url = "https://github.com/nixos/nixpkgs/archive/cb29de02c4c0e0bcb95ddbd7cc653dd720689bab.tar.gz";
  sha256 = "1daxszcvj3bq6qkki7rfzkd0f026n08xvvfx7gkr129nbcnpg24p";
}) {}));
let
  sacVCs = {
    version = "1.3.3";
    vname = "MijasCosta";
    changes = "572";
    rev = "1";
    commit = "g9eca";
  };
  libxcrypt = pkgs.callPackage ./nix/libxcrypt.nix { };
  sacStdLib = callPackage ./nix/stdlib.nix { inherit sacVCs; };
  sac2c = pkgs.callPackage ./nix/sac2c.nix { inherit sacStdLib sacVCs libxcrypt; };

  extensions = (with pkgs.vscode-extensions; [
    ms-vsliveshare.vsliveshare
    ms-python.python
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
    name = "cleanLang";
    publisher = "lucas-franceschino";
    version = "0.2.0";
    sha256 = "1i5j24mgnhm4qbzwxqvk4ps7m5knhqfsa4mdx0r7lcbxyp1i4clx";
  }]);
  vscode-with-extensions = pkgs.vscode-with-extensions.override {
    vscodeExtensions = extensions;
  };
in pkgs.mkShell {
  buildInputs = [
    sac2c
    python38
    python38Packages.matplotlib
    vscode-with-extensions
  ];
}
