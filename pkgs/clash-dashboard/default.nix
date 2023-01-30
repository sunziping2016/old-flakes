{ sources, stdenvNoCC, lib }:
let
  source = sources.clash-dashboard;
in
stdenvNoCC.mkDerivation rec {
  pname = source.pname;
  version = source.version;

  src = source.src;

  installPhase = ''
    mkdir -p $out/share/clash-dashboard
    cp -r . $out/share/clash-dashboard
  '';

  meta = with lib; {
    description = "Web port of clash";
    homepage = "https://github.com/Dreamacro/clash-dashboard";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
