{ stdenv, fetchurl, autoPatchelfHook, makeWrapper, findutils }:

stdenv.mkDerivation {
  pname = "clean-cc";
  version = "3.0";

  src = fetchurl {
    url = "https://ftp.cs.ru.nl/Clean/builds-quarterly/linux-x64/clean-bundle-complete-linux-x64-202104.tgz";
    sha256 = "05hq8cl0vppc709ff7k8j22zy3d06304cc3pzmi6jn1i7imnjbpr";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  phases = [ "unpackPhase" "installPhase" "postInstall" "fixupPhase" "postFixupPhase" ];

  installPhase = ''
    mkdir $out
    chmod -R a+rw ./
    cp -r ./* $out/
  '';

  postInstall = ''
    wrapProgram $out/bin/clm --set CLEAN_HOME $out
  '';

  postFixupPhase = ''
    ${findutils}/bin/find $out -iname '*.icl' -exec touch -h -d 2020-01-02 "{}" \;
    ${findutils}/bin/find $out -iname '*.dcl' -exec touch -h -d 2020-01-02 "{}" \;
    ls -al $out/lib/StdEnv/Clean\ System\ Files/
  '';
}
