with builtins;
rec {
  src = path { path = ./.; name = "flakes-pkgs"; };
  names = filter (v: !isNull v) (attrValues (mapAttrs (k: v: if v == "directory" && k != "_sources" then k else null) (readDir src)));
  overlay = final: prev: listToAttrs (map
    (name:
      let
        sources = final.callPackage (import ./_sources/generated.nix) { };
        package = import ./${name};
        args = intersectAttrs (functionArgs package) { inherit prev sources; };
      in
      {
        inherit name;
        value = final.callPackage package args;
      })
    names);
  packages = system: pkgs: listToAttrs (filter (pkg: elem system (pkg.value.meta.platforms or pkgs.lib.platforms.all)) (map
    (name:
      {
        inherit name;
        value = pkgs.${name};
      })
    names));
}
