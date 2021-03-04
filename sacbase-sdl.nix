{ stdenv, lib, tree, cmake, SDL, xorg, fetchFromGitHub, sac2c }:
stdenv.mkDerivation {
  name = "SacBase-SDL";

  src = fetchFromGitHub {
    owner = "SacBase";
    repo = "SDL";
    rev = "fff1155028e829bbc325ac05e77de2ebbd0c3d44";
    sha256 = "0b20pwjr1k57n7mjm6ywrnkj6gyz9mmz66m9hjjxqzvyfg64ln8b";
    fetchSubmodules = true;
  };

  configurePhase = ''
    mkdir build && cd build

    ls ~

    ${cmake}/bin/cmake \
      -DSDL_INCLUDE_DIR="${SDL.dev}/include/SDL" \
      -DSDL_LIBRARY="${SDL.out}/lib" \
      -DX11_X11_INCLUDE_PATH="${xorg.libX11.dev}/include/X11" \
      -DX11_X11_LIB="${xorg.libX11}/lib" \
      ../
  '';

  buildInputs = [ sac2c xorg.libX11 SDL.dev SDL.out ];
}
