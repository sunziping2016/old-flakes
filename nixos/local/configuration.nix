{ config, pkgs, inputs, ... }:
let
  clash-home = "/var/cache/clash";
  wrapped-hl = pkgs.writeShellScriptBin "wrapped-hl" ''
    cd ~
    export $(/run/current-system/systemd/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
    exec Hyprland
  '';
  clash-resolv = pkgs.writeText "clash-resolv" ''
    nameserver 127.0.0.1
    search .
  '';
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.sun = import ./home.nix;
    users.clash = {
      home.file = {
        "Country.mmdb".source = "${pkgs.maxmind-geoip}/share/Country.mmdb";
      };
      home.stateVersion = "22.11";
    };
    sharedModules = [
      inputs.hyprland.homeManagerModules.default
    ];
    extraSpecialArgs = { inherit inputs; };
  };

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops.key";
    secrets = {
      sun-password.neededForUsers = true;
      "clash.yaml" = {
        sopsFile = ./secrets/clash.yaml;
        format = "binary";
        owner = "clash";
      };
    };
  };

  security.sudo = {
    extraConfig = ''
      Defaults lecture="never"
    '';
    wheelNeedsPassword = false;
  };
  security.polkit.enable = true;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # {{{
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [
      (callPackage "${inputs.dhack}/dhack.nix" { })
    ];
    kernelModules = [ "dhack" ];
    # }}}
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };

  time.timeZone = "Asia/Shanghai";

  networking = {
    hostName = "local";
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = false;
    wireless.iwd = {
      enable = true;
      package = pkgs.iwd-thu;
    };
  };

  systemd.network.networks = {
    "25-wireless" = {
      name = "wlan*";
      DHCP = "yes";
    };
  };

  services = {
    tlp.enable = true;
    resolved.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd \"${wrapped-hl}/bin/wrapped-hl\" --time";
      };
    };
    printing.enable = true;
    # kmonad = {
    #   enable = true;
    #   keyboards.internal = {
    #     device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
    #     defcfg = {
    #       enable = true;
    #       fallthrough = true;
    #     };
    #     config = builtins.readFile ./kmonad/internal.kbd;
    #   };
    #   keyboards.rapoo = {
    #     device = "/dev/input/by-path/pci-0000:06:00.3-usb-0:3:1.0-event-kbd";
    #     defcfg = {
    #       enable = true;
    #       fallthrough = true;
    #     };
    #     config = builtins.readFile ./kmonad/internal.kbd;
    #   };
    # };
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    xserver.videoDrivers = [ "nvidia" ];
  };
  sound.enable = true;

  systemd.services.clash-dashboard = {
    description = "Clash dashboard";
    script = "exec ${pkgs.sfz}/bin/sfz -r -p 9001 ${pkgs.clash-dashboard}/share/clash-dashboard";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.clash = {
    enable = true;
    description = "Clash networking service";
    script = "exec ${pkgs.clash-premium}/bin/clash-premium -d ${clash-home} -f ${config.sops.secrets."clash.yaml".path} -ext-ui ${pkgs.clash-dashboard}";
    after = [ "network.target" "systemd-resolved.service" ];
    conflicts = [ "systemd-resolved.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      AmbientCapabilities = "CAP_NET_BIND_SERVICE CAP_NET_ADMIN";
      User = "clash";
      Restart = "on-failure";
      ExecStartPre = "+${pkgs.coreutils}/bin/ln -fs ${clash-resolv} /etc/resolv.conf";
      ExecStopPost = "+${pkgs.coreutils}/bin/rm -f /etc/resolv.conf";
    };
  };

  systemd.services.systemd-resolved = {
    wantedBy = pkgs.lib.mkForce [];
    serviceConfig = {
      ExecStartPre = "+${pkgs.coreutils}/bin/ln -fs /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf";
      ExecStopPost = "+${pkgs.coreutils}/bin/rm -f /etc/resolv.conf";
    };
  };

  users = {
    mutableUsers = false;
    users.sun = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      passwordFile = config.sops.secrets.sun-password.path;
      shell = pkgs.fish;
    };
    users.clash = {
      description = "Clash deamon user";
      isSystemUser = true;
      home = clash-home;
      group = "clash";
    };
    groups.clash = { };
  };

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.sun = {
      directories = [
        ".cache/Microsoft"
        ".config/1Password"
        ".config/fcitx5"
        ".config/hypr"
        ".config/microsoft-edge"
        ".config/waybar"
        ".local/share/direnv"
        ".local/share/TelegramDesktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"
        "Projects"
        { directory = ".gnupg"; mode = "0700"; }
        { directory = ".ssh"; mode = "0700"; }
      ];
      files = [
        ".local/share/fish/fish_history"
      ];
    };
    users.clash = {
      directories = [
        ".cache"
        "ProxyProviders"
        "RuleProviders"
      ];
      files = [
        "cache.db"
      ];
      home = clash-home;
    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
  hardware.nvidia = {
    powerManagement.enable = true;
    modesetting.enable = true;
    prime = {
      offload.enable = true;
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  hardware.bluetooth.enable = true;

  programs.fish = {
    enable = true;
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
  programs.dconf.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "sun" ];
  };
  programs.fuse.userAllowOther = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  fonts.enableDefaultFonts = false;
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" "Noto" ]; })
  ];
  fonts.fontconfig.defaultFonts = pkgs.lib.mkForce {
    serif = [ "Noto Serif" "Noto Serif CJK SC" ];
    sansSerif = [ "Noto Sans" "Noto Sans CJK SC" ];
    monospace = [ "JetBrains Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };

  i18n = {
    defaultLocale = "C.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
      ];
    };
  };

  system.stateVersion = "22.11";
}
