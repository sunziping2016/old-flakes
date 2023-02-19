{ prev, sources, unzip }:
prev.vscode-utils.buildVscodeExtension (
  let
    source = sources.vscode-extension-ms-vscode-cpptools;
    old = prev.vscode-extensions.ms-vscode.cpptools;
  in
  rec {
    name = builtins.replaceStrings [ "." ] [ "-" ] vscodeExtUniqueId;
    version = source.version;

    vscodeExtPublisher = "ms-vscode";
    vscodeExtName = "cpptools";
    vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";

    src = source.src;
    unpackCmd = "${unzip}/bin/unzip $curSrc";

    inherit (old) nativeBuildInputs buildInputs postFixup meta;
    postPatch = old.postPatch + ''
      chmod +x bin/cpptools-wordexp
    '';
  }
)
