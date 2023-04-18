{ prev, sources, unzip, autoPatchelfHook, stdenv }:
prev.vscode-utils.buildVscodeExtension (
  let
    source = sources.vscode-extension-github-copilot;
    old = prev.vscode-extensions.github.copilot;
  in
  # FIXME: libstdc++.so.6: cannot open shared object file: No such file or directory
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
