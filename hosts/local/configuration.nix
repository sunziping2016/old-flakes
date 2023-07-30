{ config, pkgs, inputs, ... }:
let
  clash-home = "/var/lib/clash";
  miiiw-art-z870-path = "input/by-path/uhid-0005:046D:B019.0003-event-kbd";
in
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/var/lib/sops.key";
    secrets = {
      sun-password.neededForUsers = true;
      u2f = { };
      clash-config = {
        name = "clash-config.yaml";
        owner = "clash";
        restartUnits = [ "clash.service" ];
      };
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.sun = import ./home.nix;
    sharedModules = [
      inputs.hyprland.homeManagerModules.default
    ];
    extraSpecialArgs = { inherit inputs; };
  };

  # services.openssh = {
  #   enable = true;
  #   settings.PasswordAuthentication = true;
  # };

  # region(collapsed) Clash Proxy
  home-manager.users.clash = {
    home.file = {
      "Country.mmdb".source = "${pkgs.maxmind-geoip}/share/Country.mmdb";
    };
    home.stateVersion = "23.05";
  };
  systemd.services.clash = {
    enable = true;
    description = "Clash networking service";
    # TODO: add reload support
    script = ''
      temp_file=$(mktemp)
      ${pkgs.yq-go}/bin/yq ea -eM "select(fileIndex==0)+select(fileIndex==1)" ${./clash.template.yaml} ${config.sops.secrets.clash-config.path} > $temp_file
      exec ${pkgs.clash-premium}/bin/clash-premium -d ${clash-home} -f $temp_file
    '';
    after = [ "network.target" "systemd-resolved.service" ];
    conflicts = [ "systemd-resolved.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      AmbientCapabilities = "CAP_NET_BIND_SERVICE CAP_NET_ADMIN";
      User = "clash";
      Restart = "on-failure";
    };
  };
  systemd.services.clash-resolvconf = {
    enable = true;
    description = "Clash watchdog";
    script =
      let
        clash-resolv = pkgs.writeText "clash-resolv.conf" ''
          nameserver 127.0.0.2
          search lan
        '';
      in
      ''
        online=0
        while true; do
          set +e
          ip=$(${pkgs.q}/bin/q -f json www.gstatic.com @127.0.0.2 A | ${pkgs.jq}/bin/jq -r .Answers[0].A)
          set -e
          if [ $? -eq 0 ] && ${pkgs.curl}/bin/curl -s -m 3 --resolve www.gstatic.com:80:$ip http://www.gstatic.com/generate_204; then
            new_online=1
          else
            new_online=0
          fi
          if [ $online -eq 0 ] && [ $new_online -eq 1 ]; then
            echo "Online!"
            ${pkgs.openresolv}/bin/resolvconf -m 10 -x -a Clash < ${clash-resolv}
            sleep 10
          elif [ $online -eq 1 ] && [ $new_online -eq 0 ]; then
            echo "Offline!"
            ${pkgs.openresolv}/bin/resolvconf -fd Clash
            sleep 3
          fi
          online=$new_online
        done
      '';
    bindsTo = [ "clash.service" ];
    after = [ "clash.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStopPost = "${pkgs.openresolv}/bin/resolvconf -fd Clash";
    };
  };
  services.haproxy = {
    enable = true;
    config = ''
      defaults 
        timeout connect 5s
        timeout client 1m
        timeout server 1m 

      frontend main_ssl
        bind 127.0.0.1:443
        mode tcp

        tcp-request inspect-delay 5s
        tcp-request content accept if { req_ssl_hello_type 1 }

        use_backend clash_ssl if { req_ssl_sni -m end .clash.lan }

        default_backend clash_ssl

      backend clash_ssl
        mode tcp
        server clash_ssl_server 127.0.0.1:9001 check
    '';
  };
  systemd.services.clash-dashboard = {
    description = "Clash dashboard";
    # TODO: clash.lan
    script = "exec ${pkgs.miniserve}/bin/miniserve --spa --index index.html -i 127.0.0.1 -p 9001 ${pkgs.clash-dashboard}/share/clash-dashboard";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "clash";
    };
  };
  # endregion
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
    resolvconf.useLocalResolver = false;
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
      # wifi.backend = "iwd";
    };
    wireless.networks = {
      "ChinaNet-sun".psk = "@ChinaNet-sun@";
    };
  };
  environment.etc."NetworkManager/dnsmasq.d/lan.conf".text = ''
    domain-needed
    bogus-priv
    addn-hosts=/etc/hosts
    address=/local.lan/127.0.0.1
    address=/local.lan/::1
    cache-size=10000
  '';

  security.pam.u2f = {
    enable = true;
    authFile = config.sops.secrets.u2f.path;
    cue = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    udisks2.enable = true;
    pcscd.enable = true;
    tlp.enable = true;
    resolved = {
      enable = false;
      dnssec = "false";
    };
    gvfs.enable = true;
    tumbler.enable = true;
    # udev.extraRules = ''
    #   KERNEL=="event[0-9]*", SUBSYSTEM=="input", SUBSYSTEMS=="input", ATTRS{id/vendor}=="05ac", ATTRS{id/product}=="024f", SYMLINK+="${miiiw-art-z870-path}"
    # '';
    printing.enable = true;
    # kmonad = {
    #   enable = true;
    #   keyboards = pkgs.lib.mapAttrs
    #     (_: value: {
    #       device = value;
    #       defcfg = {
    #         enable = true;
    #         fallthrough = true;
    #       };
    #       config = builtins.readFile ./kmonad/internal.kbd;
    #     })
    #     {
    #       internal = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
    #       miiiw-art-z870 = "/dev/${miiiw-art-z870-path}";
    #     };
    # };
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          # noDesktop = true;
          # enableXfwm = false;
        };
      };
      displayManager.defaultSession = "xfce";
      # windowManager.i3.enable = true;
      videoDrivers = [ "nvidia" "amd-gpu" ];
    };
  };
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${pkgs.writeShellScript "hyprland" ''
  #         export $(/run/current-system/systemd/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
  #         exec ${pkgs.hyprland}/bin/Hyprland
  #       ''}";
  #   };
  # };
  services.teamviewer.enable = true;
  sound.enable = true;

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
    storageDriver = "btrfs";
  };

  # services.create_ap = {
  #   enable = true;
  #   settings = {
  #     INTERNET_IFACE = "wlp3s0";
  #     WIFI_IFACE = "wlp3s0";
  #     SSID = "nixos-sun";
  #     #! FIXME: better password management (override config file location)
  #     PASSPHRASE = "20140615";
  #   };
  # };

  users = {
    mutableUsers = false;
    users.sun = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "wireshark" "networkmanager" ];
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
  programs.fish.enable = true;
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      {
        directory = "/etc/NetworkManager/system-connections";
        mode = "0700";
      }
      "/etc/nixos"
      "/var/log"
      "/var/lib"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.sun = {
      directories = [
        ".cache"
        ".ccnet"
        ".config"
        ".factorio"
        ".local"
        ".vscode"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"
        "Projects"
        { directory = ".gnupg"; mode = "0700"; }
        { directory = ".ssh"; mode = "0700"; }
      ];
    };
    users.clash = {
      directories = [ "." ];
      home = clash-home;
    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        # nvidia-vaapi-driver
        # mesa
        # nvidia
      ];
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

  programs.wireshark.enable = true;
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
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.evolution = {
    enable = true;
    plugins = [ pkgs.evolution-ews ];
  };
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      # xdg-desktop-portal-hyprland
      # see https://github.com/flatpak/xdg-desktop-portal-gtk/issues/355
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
    ms-fonts
  ];
  fonts.fontconfig.defaultFonts = pkgs.lib.mkForce
    {
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

  security.pki.certificates = [ (builtins.readFile ./rootCA.crt) ];

  system.stateVersion = "23.05";
}
