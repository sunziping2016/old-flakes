{ sources, stdenvNoCC, lib }:
let
  source = sources.kmonad-bin;
in
stdenvNoCC.mkDerivation rec {
  pname = source.pname;
  version = source.version;

  src = source.src;

  phases = [ "installPhase" ];
  installPhase = ''
    install -D -m755 $src $out/bin/kmonad
  '';

  meta = with lib; {
    description = "An advanced keyboard manager";
    homepage = "https://github.com/kmonad/kmonad";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
