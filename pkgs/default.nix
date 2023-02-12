rec {
  src = builtins.path { path = ./.; name = "pkgs"; };
  names = with builtins; filter (v: v != null) (attrValues (mapAttrs (k: v: if v == "directory" && k != "_sources" then k else null) (readDir src)));
  mapPackages = f: with builtins; listToAttrs (map (name: { inherit name; value = f name; }) names);
  packages = pkgs: mapPackages (name: pkgs.${name});
  overlay = final: super: mapPackages (name:
    let
      sources = final.callPackage ./_sources/generated.nix { };
      package = import ./${name};
      args = builtins.intersectAttrs (builtins.functionArgs package) { inherit super sources; };
    in
    final.callPackage package args
  );
}
