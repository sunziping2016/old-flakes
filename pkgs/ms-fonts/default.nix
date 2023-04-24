{ stdenvNoCC, lib }:
stdenvNoCC.mkDerivation {
  pname = "ms-fonts";
  version = "";

  # nativeBuildInputs = [ unzip ];

  src = fetchTarball {
    name = "ms-fonts";
    url = "http://file.szp15.com/f/24f957df23b148a89480/?dl=1";
    sha256 = "sha256:1i20pcy51nl9ziv4d2zsiafk3rki31b0gljxnxj0r2gp2baaz8la";
  };

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
