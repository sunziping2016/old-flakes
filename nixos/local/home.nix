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
      nvidiaPatches = true;
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
    zeal
    cachix
    devenv
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
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    plugins = with pkgs.fishPlugins; [
      { name = "tide"; src = tide.src; }
    ];
  };
  programs.mako = {
    enable = true;
    defaultTimeout = 5000;
  };
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    userSettings = builtins.fromJSON (builtins.readFile ./vscode/settings.json);
    extensions = (with pkgs.vscode-extensions;
      [
        ms-vscode.cpptools
      ]) ++ (with inputs.nix-vscode-extensions.extensions."${pkgs.system}".vscode-marketplace; [
      aaron-bond.better-comments
      cschlosser.doxdocgen
      eamodio.gitlens
      jnoortheen.nix-ide
      maptz.regionfolder
      mechatroner.rainbow-csv
      meezilla.json
      mkhl.direnv
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-toolsai.jupyter-keymap
      ms-vscode.cmake-tools
      ms-vscode-remote.remote-ssh
      richie5um2.vscode-sort-json
      shd101wyy.markdown-preview-enhanced
      streetsidesoftware.code-spell-checker
      vscodevim.vim
      xaver.clang-format
      yzhang.markdown-all-in-one
      # zokugun.explicit-folding
    ]) ++ [
      # pkgs.vscode-cpptools
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
    configFile = {
      "direnv/direnvrc".source = ./direnvrc;
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
