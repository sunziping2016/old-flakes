{ data, pkgs, lib, inputs, ... }: {
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.hostName = "hydra";
  networking.domain = "szp15.com";

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = data.keys;

  nix.registry = lib.mapAttrs (n: flake: { inherit flake; }) inputs;
  environment.etc = lib.mapAttrs'
    (name: flake: {
      name = "nix/inputs/${name}";
      value.source = flake.outPath;
    })
    inputs;
  nix.nixPath = [ "/etc/nix/inputs" ];

  services.postgresql = {
    package = pkgs.postgresql_15;
  };

  services.hydra = {
    enable = true;
    listenHost = "127.0.0.1";
    hydraURL = "http://127.0.0.1:3000";
    notificationSender = "me@szp.io";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
  };

  system.stateVersion = "23.05";
}
