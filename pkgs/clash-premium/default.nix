{ sources, stdenvNoCC, lib, system }:

let
  pname = "clash-premium";
  # inherit (stdenvNoCC.hostPlatform) system;
  # get a list of supported system from sources by matching names
  systems = with builtins; concatLists (filter (x: !isNull x) (map (match "${pname}-(.*)") (attrNames sources)));
  # systems = [ "x86_64-linux" ];
in
stdenvNoCC.mkDerivation rec {
  pname = "clash-premium";
  inherit (sources."${pname}-${system}") version src;

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/clash-premium.gz
    gzip --decompress $out/bin/clash-premium.gz
    chmod +x $out/bin/clash-premium
  '';

  meta = with lib; {
    homepage = https://github.com/Dreamacro/clash;
    description = "Close-sourced pre-built Clash binary with TUN support and more";
    license = licenses.unfree;
    platforms = systems;
  };
}
