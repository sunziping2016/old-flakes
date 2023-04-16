{ stdenvNoCC, sources, gtk-engine-murrine, lib }:
let
  source = sources.sweet;
in
stdenvNoCC.mkDerivation
{
  # TODO: sddm
  # TODO: Qt no transparent
  pname = source.pname;
  version = source.version;

  src = source.src;

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes/Sweet
    cp -a $src/{Art,assets,cinnamon,extras,gnome-shell,gtk-2.0,gtk-3.0,gtk-4.0,kde,metacity-1,xfwm4,index.theme} $out/share/themes/Sweet
    runHook postInstall
  '';

  meta = with lib; {
    description = "Light and dark colorful Gtk3.20+ theme";
    homepage = "https://github.com/EliverLara/Sweet";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ fuzen ];
    platforms = platforms.linux;
  };
}
