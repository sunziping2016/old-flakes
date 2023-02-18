{ prev, handlr, writeShellScriptBin }:
prev.xdg-utils.overrideAttrs (oldAttrs: {
  postInstall = oldAttrs.postInstall + ''
    cp ${writeShellScriptBin "xdg-open" "${handlr}/bin/handlr open \"$@\""}/bin/xdg-open $out/bin/xdg-open
  '';
})
