{ stdenv, lib, bash, cmake, gcc, SDL, hwloc, cudnn, libuuid, makeWrapper, fetchurl, fetchFromGitHub, tree, python27 }:
stdenv.mkDerivation {
  pname = "sac";
  version = "v1.3.3-386-1";

  srcs = [
    (fetchurl {
      url = "https://gitlab.science.ru.nl/sac-group/sac-packages/-/raw/master/packages/weekly/Linux/1.3.3-386-1/full/sac2c-1.3.3-MijasCosta-386-g66d20-omnibus.tar.gz";
      name = "sac2c";
      sha256 = "0jrw36lpz6dm0a6xkgq6xmq6vfzyiz1da7a0vxv6bwkzz7wd0vdy";
    })
    (fetchurl {
      url = "https://gitlab.science.ru.nl/sac-group/sac-packages/-/raw/master/packages/weekly/Linux/1.3.3-386-1/full/sac-stdlib-1.3-81-g930d.tar.gz";
      name = "sac-stdlib";
      sha256 = "1cjy8bixm2m1dl1k0z84wd3qvhmjl9phqkzcpxcbqmnpbbadigy7";
    })
    (fetchFromGitHub {
      owner = "SacBase";
      repo = "SDL";
      rev = "fff1155028e829bbc325ac05e77de2ebbd0c3d44";
      sha256 = "0b20pwjr1k57n7mjm6ywrnkj6gyz9mmz66m9hjjxqzvyfg64ln8b";
      fetchSubmodules = true;
    })
  ];

  sourceRoot = "sac2c";

  phases = [ "unpackPhase" "patchPhase" "installPhase" "fixupPhase"];

  unpackPhase = ''
    mkdir sac2c sac-stdlib sac2c/sac-sdl
    set -- $srcs
    tar -xf $1 -C sac2c
    tar -xf $2 -C sac-stdlib
    cp -r sac-stdlib/sac-stdlib-1.3-81-g930d/usr/local/* sac2c
    cp -r $3/* sac2c/sac-sdl
  '';

  patchPhase = ''
    chmod +rwx ./install.sh

    # patch shebangs
    sed -i 's@#!/usr/bin/env bash@#!${bash}/bin/bash@' install.sh 
    sed -i 's@#!/usr/sbin/python2@#!${python27}/bin/python@' sac2c-version-manager

    # FUCK THIS SHIT BUILD SYSTEM
    # WHY DOES EVERYTHING SUCK????
    sed -i "s@#define SAC2CRC_BUILD_DIR \"/builds/gitlab/sac-group/build-sac-pkgs/sac2c-build/sac2c-release/src/sac2c-release-build/\"@#define SAC2CRC_BUILD_DIR \"$out\"@" src/sacdirs.h
    sed -i "s@#define DLL_BUILD_DIR \"/builds/gitlab/sac-group/build-sac-pkgs/sac2c-build/sac2c-release/src/sac2c-release-build/lib\"@#define DLL_BUILD_DIR \"$out/libexec/sac2c/1.3.3-MijasCosta-386-g66d20\"@" src/sacdirs.h
    
    sed -i "s@/usr/sbin/cc@${gcc}/bin/gcc@" share/sac2c/1.3.3-MijasCosta-386-g66d20/sac2crc_d
    sed -i "s@/usr/sbin/cc@${gcc}/bin/gcc@" share/sac2c/1.3.3-MijasCosta-386-g66d20/sac2crc_p
    sed -i "s@/usr/sbin/cc@${gcc}/bin/gcc@" src/sacdirs.h

    sed -i 's@VERBOSE=0@VERBOSE=1@' installers/installer-release.sh
    sed -i 's@VERBOSE=0@VERBOSE=1@' installers/installer-debug.sh

    # We want to get symlinks in bin to execute
    sed -i 's@SYMLINK=0@SYMLINK=1@' installers/installer-release.sh
    sed -i 's@SYMLINK=0@SYMLINK=1@' installers/installer-debug.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    ./install.sh -i $out

    # I don't understand why this is necessary because
    # I expected the fixupPhase to do this. But it does not.
    patchelf --set-rpath ${libuuid.out}/lib $out/libexec/sac2c/1.3.3-MijasCosta-386-g66d20/libsac2c_p.so
    patchelf --set-rpath ${libuuid.out}/lib $out/libexec/sac2c/1.3.3-MijasCosta-386-g66d20/libsac2c_d.so

    # Why does this not work?
    wrapProgram $out/bin/sac2c_p \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
          hwloc.lib
          cudnn
          SDL
        ]}"
  '';

  buildInputs = [ bash python27 makeWrapper SDL ];

}
