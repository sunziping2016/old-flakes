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
      package = pkgs.hyprland;
      xwayland.hidpi = true;
      systemdIntegration = false;
      nvidiaPatches = true;
      extraConfig = ''
        exec-once = export WAYLAND_DISPLAY DISPLAY && ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP PATH && systemctl --user start hyprland-session.target
        exec-once = hyprctl setcursor ${cursorTheme.name} ${toString cursorTheme.size}
      '' + builtins.readFile ./hyprland.conf;
    };
  home.packages = with pkgs; [
    # Shell
    ## CLI utilities
    fd
    ripgrep
    sd
    exa
    bat
    zoxide
    miniserve
    bandwhich
    joshuto
    du-dust
    tokei
    hexyl
    q
    delta
    procs
    docker-compose
    azure-cli
    mtr
    htop
    # Others
    xdg-utils
    prime-run
    handlr
    jq
    p7zip
    cachix
    kitty
    nix-tree
    # wayland apps
    hyprpaper
    (rofi-wayland.override {
      symlink-dmenu = true;
    })
    # GNOME apps
    # gnome.gnome-calendar
    evince
    # heavy apps
    feishu
    zeal
    vlc
    microsoft-edge
    gimp
    inkscape
    wpsoffice
    tdesktop
    steam-run
    texlive.combined.scheme-full
    seafile-client
    wireshark
    dfeet
    # xfce suite
    xfce.mousepad
    xfce.ristretto
    networkmanagerapplet
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
    loginShellInit = ''
      export (/run/current-system/systemd/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
    '';
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set flake "$HOME/Projects/flakes"
    '';
    plugins = with pkgs.fishPlugins; [
      { name = "tide"; src = tide.src; }
    ];
  };
  services.mako = {
    enable = true;
    borderRadius = 10;
    defaultTimeout = 5000;
  };
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    userSettings = (builtins.fromJSON (builtins.readFile ./vscode/settings.json)) // {
      "haskell.serverExecutablePath" = "${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings" = {
        "nil" = {
          # "diagnostics" = {
          #   "ignored" = [ "unused_binding" "unused_with" ];
          # };
          "formatting" = {
            "command" = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
          };
        };
      };
      # Actually, it's ignored when the language server is enabled. See Nix IDE details page.
      "nix.formatterPath" = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
    };
    extensions = (with pkgs.vscode-extensions;
      [
      ]) ++ (with (pkgs.forVSCodeVersion pkgs.vscode.version).vscode-marketplace; [
      aaron-bond.better-comments
      bungcip.better-toml
      cschlosser.doxdocgen
      editorconfig.editorconfig
      github.copilot-labs
      github.vscode-pull-request-github
      golang.go
      haskell.haskell
      james-yu.latex-workshop
      jnoortheen.nix-ide
      justusadam.language-haskell
      leanprover.lean4
      maptz.regionfolder
      mechatroner.rainbow-csv
      meezilla.json
      mkhl.direnv
      ms-azuretools.vscode-docker
      ms-python.black-formatter
      ms-python.isort
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-toolsai.jupyter-keymap
      ms-vscode.cmake-tools
      ms-vscode.makefile-tools
      ms-vscode.remote-explorer
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vsliveshare.vsliveshare
      redhat.vscode-yaml
      #! FIXME: incompatible
      # richie5um2.vscode-sort-json
      rreverser.llvm
      signageos.signageos-vscode-sops
      shd101wyy.markdown-preview-enhanced
      streetsidesoftware.code-spell-checker
      tintinweb.graphviz-interactive-preview
      twxs.cmake
      vscodevim.vim
      xaver.clang-format
      yzhang.markdown-all-in-one
    ]) ++ (with (pkgs.forVSCodeVersion pkgs.vscode.version).vscode-marketplace-release; [
      eamodio.gitlens
      rust-lang.rust-analyzer
    ]) ++ [
      pkgs.vscode-extension-github-copilot
      pkgs.vscode-extension-ms-vscode-cpptools #?
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

      # TODO(medium): use VS Code as Git tool https://www.roboleary.net/vscode/2020/09/15/vscode-git.html
      merge.tool = "nvimdiff";
      mergetool = {
        keepBackup = false;
        keepTemporaries = false;
        writeToTemp = true;
      };
      fetch.prune = true;

      # region(collapsed) https://github.com/dandavison/delta
      core.pager = "${pkgs.delta}/bin/delta";
      interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
      delta = {
        navigate = true;
        light = false;
        line-numbers = true;
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      # endregion
    };
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };
  programs.ssh = {
    enable = true;
    compression = true;
    serverAliveInterval = 30;
    matchBlocks = {
      hydra = {
        user = "root";
        hostname = "sh1.szp15.com";
      };
    };
    extraConfig = ''
      CheckHostIP no
    '';
  };
  xdg = {
    enable = true;
    userDirs.enable = true;
    configFile = {
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
