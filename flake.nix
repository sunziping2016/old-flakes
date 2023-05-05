{
  description = ''NixOS configuration from "Ziping Sun <me@szp.io>"'';

  outputs = { self, nixpkgs, flake-parts, ... }@inputs:
    let
      this = import ./pkgs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem = { system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
            ];
          };
        in
        {
          packages = this.packages system pkgs;
          legacyPackages = pkgs;

          devShells.default = with pkgs; mkShell {
            nativeBuildInputs = [ nvfetcher sops colmena ];
          };
          formatter = pkgs.nixpkgs-fmt;
        };
      flake = {
        overlays.default = this.overlay;
        nixosConfigurations.local = import ./hosts/local inputs;
        # nixosConfigurations.aliyun-sh1 = import ./hosts/local inputs;
      };
    };

  inputs = {
    dhack = {
      url = "github:NickCao/dhack";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # use only modules, packages are from nixpkgs.
    hyprland.url = "github:hyprwm/Hyprland";
    impermanence.url = "github:nix-community/impermanence";
    kmonad = {
      url = "github:kmonad/kmonad?submodules=1&dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };
}
