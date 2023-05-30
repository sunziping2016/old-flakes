# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  clash-dashboard = {
    pname = "clash-dashboard";
    version = "bd9971a0aad807cf121c29bf20c55f7a82d02043";
    src = fetchgit {
      url = "https://github.com/Dreamacro/clash-dashboard.git";
      rev = "bd9971a0aad807cf121c29bf20c55f7a82d02043";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-hLDAJLQPtyaoTS+Y0GjzDBqdyF68idOajmQGJXiE/nQ=";
    };
    date = "2023-04-29";
  };
  clash-premium-x86_64-linux = {
    pname = "clash-premium-x86_64-linux";
    version = "2023.05.29";
    src = fetchurl {
      url = "https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-2023.05.29.gz";
      sha256 = "sha256-qyKo1NWbkEQRpOhwr+nyia08fHqo5yAfSK6E2Hgl/Ks=";
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
    version = "20230512";
    src = fetchurl {
      url = "https://github.com/Dreamacro/maxmind-geoip/releases/download/20230512/Country.mmdb";
      sha256 = "sha256-/QIii+f7pOzXXlhDQV6XGHpyjAlCS/OONalbPSnmArE=";
    };
  };
  sweet = {
    pname = "sweet";
    version = "36a6932956c7712a1873c07624a3fefa6b4fb278";
    src = fetchgit {
      url = "https://github.com/EliverLara/Sweet.git";
      rev = "36a6932956c7712a1873c07624a3fefa6b4fb278";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-rAytpp3F5V5xMl4srrIdCaonmWWvY7z78WpXnI/Cyd8=";
    };
    date = "2023-06-04";
  };
  vscode-extension-github-copilot = {
    pname = "vscode-extension-github-copilot";
    version = "1.88.132";
    src = fetchurl {
      url = "https://github.gallery.vsassets.io/_apis/public/gallery/publisher/github/extension/copilot/1.88.132/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      name = "copilot-1.88.132.zip";
      sha256 = "sha256-+iqcZ87x5O5JLQYtRe3hJkM9+h6U6feZnZrnCvVCqYE=";
    };
  };
  vscode-extension-ms-vscode-cpptools = {
    pname = "vscode-extension-ms-vscode-cpptools";
    version = "v1.15.4";
    src = fetchurl {
      url = "https://github.com/microsoft/vscode-cpptools/releases/download/v1.15.4/cpptools-linux.vsix";
      sha256 = "sha256-Fz/8zgPLq6nYnDEk9zkQp5y4uTnDJma6MbFpTJrJhGo=";
    };
  };
}
