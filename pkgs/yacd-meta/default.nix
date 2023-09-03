{ sources, stdenvNoCC, lib }:
let
  source = sources.yacd-meta;
in
stdenvNoCC.mkDerivation {
  pname = source.pname;
  version = source.version;

  src = source.src;

  installPhase = ''
    mkdir -p $out/share/yacd-meta
    cp -r . $out/share/yacd-meta
  '';

  meta = with lib; {
    description = "Web port of clash";
    homepage = "Yet Another Clash Dashboard";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
