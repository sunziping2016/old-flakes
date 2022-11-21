{ sources, stdenvNoCC, lib }:
let
  source = sources.maxmind-geoip;
in
stdenvNoCC.mkDerivation rec {
  pname = source.pname;
  version = source.version;

  src = source.src;

  phases = [ "installPhase" ];
  installPhase = ''
    install -D -m755 $src $out/Country.mmdb
  '';

  meta = with lib; {
    description = "Maxmind GeoIP database";
    homepage = "https://github.com/Dreamacro/maxmind-geoip";
    license = licenses.unfreeRedistributable;
    platforms = platforms.all;
  };
}
