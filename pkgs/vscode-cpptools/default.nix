{ prev, sources, lib, musl, unzip }:
prev.vscode-utils.buildVscodeExtension (
  let
    old = prev.vscode-extensions.ms-vscode.cpptools;
  in
  rec {
    name = "ms-vscode-cpptools";
    version = sources.vscode-cpptools.version;

    vscodeExtPublisher = "ms-vscode";
    vscodeExtName = "cpptools";
    vscodeExtUniqueId = "ms-vscode.cpptools";

    src = sources.vscode-cpptools.src;
    unpackCmd = "${unzip}/bin/unzip $curSrc";

    inherit (old) nativeBuildInputs buildInputs postFixup meta;
    postPatch = old.postPatch + ''
      chmod +x bin/cpptools-wordexp
    '';
  }
)
