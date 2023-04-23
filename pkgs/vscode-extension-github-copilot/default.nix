{ prev, sources, unzip, autoPatchelfHook, stdenv }:
prev.vscode-utils.buildVscodeExtension (
  let
    source = sources.vscode-extension-github-copilot;
    old = prev.vscode-extensions.github.copilot;
  in
  rec {
    name = builtins.replaceStrings [ "." ] [ "-" ] vscodeExtUniqueId;
    version = source.version;

    vscodeExtPublisher = "github";
    vscodeExtName = "copilot";
    vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";

    nativeBuildInputs = [
      unzip
      autoPatchelfHook
      stdenv.cc.cc.lib
    ];
    src = source.src;

    inherit (old) meta;
  }
)
