{ config, pkgs, inputs, ... }:
let
  clash-home = "/var/lib/clash";
in
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    # age.keyFile = "/var/lib/sops.key";
    secrets = {
      sun-password.neededForUsers = true;
      u2f = { };
      "clash-config.yaml" = {
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
    extraSpecialArgs = { inherit inputs; };
  };

  home-manager.users.clash = {
    home.file = {
      "Country.mmdb".source = "${pkgs.maxmind-geoip}/share/Country.mmdb";
    };
    home.stateVersion = "23.05";
  };
  systemd.services.clash = {
    enable = true;
    description = "Clash networking service";
    script = ''
      temp_file=$(mktemp)
      ${pkgs.yq-go}/bin/yq ea -eM "select(fileIndex==0)+select(fileIndex==1)" ${./clash.yaml} ${config.sops.secrets."clash-config.yaml".path} > $temp_file
      exec ${pkgs.clash-premium}/bin/clash-premium -d ${clash-home} -f $temp_file
    '';
    after = [ "network.target" ];
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
          ip=$(${pkgs.q}/bin/q --format=json www.gstatic.com @127.0.0.2 A | ${pkgs.jq}/bin/jq -r .Answers[0].A)
          set -e
          if [ $? -eq 0 ] && ${pkgs.curl}/bin/curl -s -m 3 --resolve www.gstatic.com:80:$ip http://www.gstatic.com/generate_204; then
            new_online=1
          else
            new_online=0
          fi
          if [ $online -eq 0 ] && [ $new_online -eq 1 ]; then
            echo "Online!"
            ${pkgs.openresolv}/bin/resolvconf -m 10 -x -a Clash < ${clash-resolv}
          elif [ $online -eq 1 ] && [ $new_online -eq 0 ]; then
            echo "Offline!"
            ${pkgs.openresolv}/bin/resolvconf -fd Clash
          fi
          online=$new_online
          if [ $online -eq 0 ]; then
            sleep 5
          else
            sleep 60
          fi
        done
      '';
    bindsTo = [ "clash.service" ];
    after = [ "clash.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStopPost = "${pkgs.openresolv}/bin/resolvconf -fd Clash";
    };
  };

  systemd.services.clash-dashboard = {
    description = "Clash dashboard";
    script = "exec ${pkgs.miniserve}/bin/miniserve --spa --index index.html -i 127.0.0.1 -p 9001 ${pkgs.clash-dashboard}/share/clash-dashboard";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "clash";
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

    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };

  time.timeZone = "Asia/Shanghai";

  networking = {
    hostName = "local";
    useDHCP = false;
    firewall.enable = false;
    resolvconf.useLocalResolver = false;
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
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
    printing.enable = true;
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
        };
      };
      displayManager.defaultSession = "xfce";
      videoDrivers = [ "nvidia" "amd-gpu" ];
    };
  };

  # services.teamviewer.enable = true;
  sound.enable = true;

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      enableNvidia = true;
      autoPrune.enable = true;
      defaultNetwork.settings = { dns_enabled = true; };
    };
    containers = {
      storage.settings = {
        storage = {
          driver = "btrfs";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";
        };
      };
    };
  };

  users = {
    mutableUsers = false;
    users.sun = {
      isNormalUser = true;
      extraGroups = [ "wheel" "podman" "wireshark" "networkmanager" ];
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
        "Torrents"
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
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
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
  environment.systemPackages = with pkgs; [
    # xfce
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-whiskermenu-plugin
  ];
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  fonts.enableDefaultPackages = false;
  fonts.packages = with pkgs; [
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

  services.xserver.xkbOptions = "ctrl:nocaps";
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
  console.useXkbConfig = true;

  programs.bcc.enable = true;

  systemd.network.wait-online = {
    anyInterface = true;
    extraArgs = [
      "--interface=enp2s0"
      "--interface=wlp3s0"
    ];
  };

  system.stateVersion = "23.05";
}
