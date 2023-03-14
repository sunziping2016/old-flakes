{ sources, stdenvNoCC, lib }:
stdenvNoCC.mkDerivation rec {
  pname = "ms-fonts";
  version = "0.0.0";

  # nativeBuildInputs = [ unzip ];

  src = ./Fonts.tar.gz;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp *.{ttf,TTF,ttc,TTC} $out/share/fonts/truetype
  '';

  meta = with lib; {
    description = "Microsoft Fonts";
    homepage = "https://learn.microsoft.com/en-us/typography/font-list/";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
