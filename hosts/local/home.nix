{ pkgs, ... }:
{
  systemd.user = {
    sessionVariables = {
      EDITOR = "nvim";
      # input method
      GLFW_IM_MODULE = "ibus";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      # ssh
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
      # portal
      GTK_USE_PORTAL = "1";
    };
  };
  gtk = {
    enable = true;
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
    # gnome.gnome-calendar
    evince
    # heavy apps
    feishu
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
    networkmanagerapplet
  ];
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
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;
  };
  programs.gpg = {
    enable = true;
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
  };

  home.stateVersion = "23.05";
}
