# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  clash-dashboard = {
    pname = "clash-dashboard";
    version = "595ba59c43b8f3ca721be0494bf7eae21a7f031d";
    src = fetchgit {
      url = "https://github.com/Dreamacro/clash-dashboard.git";
      rev = "595ba59c43b8f3ca721be0494bf7eae21a7f031d";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-3KmVcn6GhCxbeSpD8tqJIX2TWIirW5/zbuT/AqmBDDo=";
    };
    date = "2023-02-28";
  };
  clash-premium-x86_64-linux = {
    pname = "clash-premium-x86_64-linux";
    version = "2023.03.04";
    src = fetchurl {
      url = "https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-2023.03.04.gz";
      sha256 = "sha256-BO+TtKTDvJYnLqRx/SZZFMz0o4QSEP4xKUqMlZotq8g=";
    };
  };
  kmonad-bin = {
    pname = "kmonad-bin";
    version = "0.4.1";
    src = fetchurl {
      url = "https://github.com/kmonad/kmonad/releases/download/0.4.1/kmonad-0.4.1-linux";
      sha256 = "sha256-g55Y58wj1t0GhG80PAyb4PknaYGJ5JfaNe9RlnA/eo8=";
    };
  };
  maxmind-geoip = {
    pname = "maxmind-geoip";
    version = "20230212";
    src = fetchurl {
      url = "https://github.com/Dreamacro/maxmind-geoip/releases/download/20230212/Country.mmdb";
      sha256 = "sha256-Tnma6tpET4Vrm5G8KmLpsVnpD2JIKts56kZQsBIbRZ8=";
    };
  };
  sweet = {
    pname = "sweet";
    version = "802857775599ecb40521defb1f834239c501d372";
    src = fetchgit {
      url = "https://github.com/EliverLara/Sweet.git";
      rev = "802857775599ecb40521defb1f834239c501d372";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-XNd+XeYXTW/2LVZdNTT0ecq5R7HFAUvfRRtuMCQJW9A=";
    };
    date = "2023-02-27";
  };
  vscode-extension-github-copilot = {
    pname = "vscode-extension-github-copilot";
    version = "1.77.9225";
    src = fetchurl {
      url = "https://github.gallery.vsassets.io/_apis/public/gallery/publisher/github/extension/copilot/1.77.9225/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "copilot-1.77.9225.zip";
      sha256 = "sha256-tRAjWiaUIkAULfgWWAKVVz7Zgugw0CQtFIdvf9fhmKs=";
    };
  };
  vscode-extension-ms-vscode-cpptools = {
    pname = "vscode-extension-ms-vscode-cpptools";
    version = "v1.14.4";
    src = fetchurl {
      url = "https://github.com/microsoft/vscode-cpptools/releases/download/v1.14.4/cpptools-linux.vsix";
      sha256 = "sha256-ToQnYMZ/MvpidSgE3mtJPAPay3+/VIPUabPPnbmPqf8=";
    };
  };
  yacd = {
    pname = "yacd";
    version = "v0.3.8";
    src = fetchurl {
      url = "https://github.com/haishanh/yacd/releases/download/v0.3.8/yacd.tar.xz";
      sha256 = "sha256-1dfs3pGnCKeThhFnU+MqWfMsjLjuyA3tVsOrlOURulA=";
    };
  };
}
