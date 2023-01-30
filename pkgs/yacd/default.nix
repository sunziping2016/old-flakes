{ sources, stdenvNoCC, lib }:
let
  source = sources.yacd;
in
stdenvNoCC.mkDerivation rec {
  pname = source.pname;
  version = source.version;

  src = source.src;

  postPatch = ''
    substituteInPlace assets/index.*.js --replace './/sw.js' './sw.js'
  '';

  installPhase = ''
    mkdir -p $out/share/yacd
    cp -r . $out/share/yacd
  '';

  meta = with lib; {
    description = "Yet Another Clash Dashboard";
    homepage = "https://github.com/haishanh/yacd";
    license = licenses.free;
    platforms = platforms.all;
  };
}
