{ pkgs, lib, config, inputs, ... }:
{
  systemd.user = {
    sessionVariables = {
      EDITOR = "nvim";
      # LIBVA_DRIVER_NAME = "nvidia";
      # GBM_BACKEND = "nvidia-drm";
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # WLR_DRM_DEVICES = "/dev/dri/card0"; # nvidia
      WLR_NO_HARDWARE_CURSORS = "1";
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
      # portal
      GTK_USE_PORTAL = "1";
      # QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_STYLE_OVERRIDE = "kvantum";
      QT_FONT_DPI = "120";
    };
  };
  gtk = {
    enable = true;
    theme = {
      package = pkgs.sweet;
      name = "Sweet";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
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
  wayland.windowManager.hyprland =
    let
      cursorTheme = config.gtk.cursorTheme;
    in
    {
      enable = true;
      systemdIntegration = false;
      nvidiaPatches = true;
      extraConfig = ''
        exec-once = export WAYLAND_DISPLAY DISPLAY && ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP PATH && systemctl --user start hyprland-session.target
        exec-once = hyprctl setcursor ${cursorTheme.name} ${toString cursorTheme.size}
      '' + builtins.readFile ./hyprland.conf;
    };
  home.packages = with pkgs; [
    xdg-utils
    prime-run
    kitty
    handlr
    htop
    jq
    unzip
    zeal
    cachix
    # wayland apps
    hyprpaper
    # heavy apps
    vlc
    microsoft-edge
    gimp
    wpsoffice
    tdesktop
    steam-run
    # xfce suite
    xfce.thunar
    xfce.mousepad
    xfce.ristretto
    # rust/go suite
    bat
    fd
    sd
    ripgrep
    bandwhich
    joshuto
    scc
    (rofi-wayland.override {
      symlink-dmenu = true;
    })
    # KDE suite
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.kio-extras
    papirus-icon-theme
  ];
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "hyprland-session.target";
    package = pkgs.waybar-hyprland;
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set flake "$HOME/Projects/flakes"
    '';
    plugins = with pkgs.fishPlugins; [
      { name = "tide"; src = tide.src; }
    ];
  };
  services.dunst = {
    enable = true;
  };
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    userSettings = builtins.fromJSON (builtins.readFile ./vscode/settings.json);
    extensions = (with pkgs.vscode-extensions;
      [
      ]) ++ (with pkgs.vscode-marketplace; [
      aaron-bond.better-comments
      bungcip.better-toml
      cschlosser.doxdocgen
      eamodio.gitlens
      editorconfig.editorconfig
      # github.vscode-pull-request-github
      jnoortheen.nix-ide
      leanprover.lean4
      maptz.regionfolder
      mechatroner.rainbow-csv
      meezilla.json
      mkhl.direnv
      ms-azuretools.vscode-docker
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-toolsai.jupyter-keymap
      ms-vscode.cmake-tools
      ms-vscode.makefile-tools
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vsliveshare.vsliveshare
      redhat.vscode-yaml
      richie5um2.vscode-sort-json
      rreverser.llvm
      shd101wyy.markdown-preview-enhanced
      streetsidesoftware.code-spell-checker
      twxs.cmake
      vscodevim.vim
      xaver.clang-format
      yzhang.markdown-all-in-one

      # eliverlara.sweet-vscode
      # eliverlara.sweet-vscode-icons
    ]) ++ [
      pkgs.vscode-extension-github-copilot
      pkgs.vscode-extension-ms-vscode-cpptools
    ];
    # mutableExtensionsDir = false;
  };
  programs.gpg = {
    enable = true;
    # mutableKeys = false;
    # mutableTrust = false;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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
    configFile = {
      "direnv/direnvrc".source = ./direnvrc;
      "Kvantum/Sweet".source = "${pkgs.sweet}/share/themes/Sweet/kde/Kvantum/Sweet";
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=Sweet
      '';
    };
  };

  # template from https://nixos.wiki/wiki/Polkit
  systemd.user.services.polkit-kde-agent-1 = {
    Unit = {
      Description = "polkit-kde-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
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
