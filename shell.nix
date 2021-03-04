with import <nixpkgs> {};
let sac = pkgs.callPackage ./sac2c.nix { };
    # sac-sdl = pkgs.callPackage ./sacbase-sdl.nix {
    #   sac2c = sac;
    # };
in pkgs.mkShell {
  # TODO: Find a way to move the library dependencies into the sac derivation
  buildInputs = [
    hwloc.lib
    cudnn
    sac
    #sac-sdl
  ];
}
