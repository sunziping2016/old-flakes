{ self, nixpkgs, devenv, ... }@inputs:
nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware.nix
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    inputs.kmonad.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    {
      nix = {
        settings = {
          trusted-users = [ "root" "sun" ];
          substituters = [
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
            "https://cache.nixos.org"
            "https://hyprland.cachix.org"
            "https://nixpkgs-wayland.cachix.org"
            "https://devenv.cachix.org"
          ];
          trusted-public-keys = [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        self.overlays.default
        (final: super: {
          devenv = devenv.packages.${system}.devenv;
        })
        inputs.nixpkgs-wayland.overlay
        inputs.hyprland.overlays.default
        inputs.hyprpaper.overlays.default
      ];
    }
  ];
  specialArgs = {
    inherit inputs;
  };
}
