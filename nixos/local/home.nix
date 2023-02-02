{ pkgs, lib, config, inputs, ... }:
{
  systemd.user = {
    sessionVariables = {
      EDITOR = "nvim";
      LIBVA_DRIVER_NAME = "nvidia";
      # recommended by Hyprland
      GDK_BACKEND = "wayland,x11";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      NIXOS_OZONE_WL = "1";
      XCURSOR_SIZE = toString config.gtk.cursorTheme.size;
      XDG_SESSION_TYPE = "wayland";
      # input method
      GLFW_IM_MODULE = "ibus"; # IME support in kitty
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      # ssh
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
    };
  };
  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
    cursorTheme = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 24;
    };
    font = {
      package = pkgs.roboto;
      name = "Roboto";
      size = 11;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };
  wayland.windowManager.hyprland =
    let
      cursorTheme = config.gtk.cursorTheme;
    in
    {
      enable = true;
      systemdIntegration = false;
      extraConfig = ''
        exec-once = export WAYLAND_DISPLAY DISPLAY && ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP PATH && systemctl --user start hyprland-session.target
        exec-once = hyprctl setcursor ${cursorTheme.name} ${toString cursorTheme.size}
      '' + builtins.readFile ./hyprland.conf;
    };
  home.packages = with pkgs; [
    xdg-utils
    hyprpaper
    prime-run
    tdesktop
    wpsoffice
    vifm
    xfce.thunar
    kitty
    microsoft-edge
    handlr
    htop
    fd
    ripgrep
    jq
    unzip
    nixpkgs-fmt
    sops
    (rofi-wayland.override {
      symlink-dmenu = true;
    })
  ];
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "hyprland-session.target";
    package = pkgs.waybar-hyprland;
  };
  programs.mako = {
    enable = true;
    defaultTimeout = 5000;
  };
  programs.vscode = {
    enable = true;
    # userSettings = builtins.fromJSON (builtins.readFile ./vscode/settings.json);
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      yzhang.markdown-all-in-one
      vscodevim.vim
      ms-vscode.cpptools
      ms-vscode.cmake-tools
      xaver.clang-format
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      mechatroner.rainbow-csv
      ms-python.python
    ];
    # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #   {
    #     name = "xaver.clang-format";
    #     publisher = "xaver";
    #     version = "1.9.0";
    #     sha256 = "166ia73vrcl5c9hm4q1a73qdn56m0jc7flfsk5p5q41na9f10lb0";
    #   }
    # ];
    # mutableExtensionsDir = false;
  };
  programs.gpg = {
    enable = true;
    # mutableKeys = false;
    # mutableTrust = false;
  };
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    userEmail = "me@szp.io";
    userName = "Ziping Sun";
    extraConfig = {
      commit.gpgSign = true;
      init.defaultBranch = "master";
    };
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };
  xdg = {
    enable = true;
    userDirs.enable = true;
  };
  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "hyprland compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [
        "graphical-session-pre.target"
        "xdg-desktop-autostart.target"
      ];
      After = [ "graphical-session-pre.target" ];
    };
  };
  # systemd.user.services.fcitx5-daemon.Service.ExecStart = lib.mkForce "${pkgs.coreutils-full}/bin/true";
  home.stateVersion = "22.11";
}
