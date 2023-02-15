{ super, sources, lib, musl }:
(super.vscode-utils.extensionFromVscodeMarketplace
  {
    name = "cpptools";
    publisher = "ms-vscode";
    version = sources.vscode-cpptools.version;
    sha256 = sources.vscode-cpptools.src.outputHash;
  }).overrideAttrs (_:
let
  old = super.vscode-extensions.ms-vscode.cpptools;
  postPatchLines = lib.strings.splitString "\n" old.postPatch;
  # drop last three lines
  postPatchs = with lib.lists; reverseList (drop 0 (reverseList postPatchLines));
in
rec {
  inherit (old) nativeBuildInputs postFixup;
  buildInputs = old.buildInputs ++ [ musl ];
  postPatch = old.postPatch + ''
    chmod +x bin/cpptools-wordexp
  '';
})
