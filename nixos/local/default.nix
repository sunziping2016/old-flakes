{ self, nixpkgs, ... }@inputs:
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
            "https://sunziping2016.cachix.org"
          ];
          trusted-public-keys = [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
	    "sunziping2016.cachix.org-1:rTPJkYOgU+WCgNsVI85QeJGTeeyCrExE5Gj4wxD/7lg="
          ];
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        self.overlays.default
        # inputs.nixpkgs-wayland.overlay
        inputs.hyprland.overlays.default
        inputs.hyprpaper.overlays.default
        inputs.nix-vscode-extensions.overlays.default
      ];
    }
  ];
  specialArgs = {
    inherit inputs;
  };
}
