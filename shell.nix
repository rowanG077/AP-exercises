with import <nixpkgs> {};
let sac = pkgs.callPackage ./. { };
in pkgs.mkShell {
  # TODO: Find a way to move the library dependencies into the sac derivation
  buildInputs = [
    hwloc.lib
    cudnn
    sac
  ];
}
