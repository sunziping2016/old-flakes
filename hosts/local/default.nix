{ self, nixpkgs, ... }@inputs:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware.nix
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.nix-index-database.nixosModules.nix-index
    {
      nix = {
        settings = {
          trusted-users = [ "root" "sun" ];
          substituters = [
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
            "https://cache.nixos.org"
          ];
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        inputs.nvfetcher.overlays.default
        self.overlays.default
      ];
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      nix.registry.p.flake = self;
    }
  ];
  specialArgs = {
    inherit inputs;
  };
}
