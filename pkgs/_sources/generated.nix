# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  clash-dashboard = {
    pname = "clash-dashboard";
    version = "bc9a00b134f4e1b648788ca6518389f822f80017";
    src = fetchgit {
      url = "https://github.com/Dreamacro/clash-dashboard.git";
      rev = "bc9a00b134f4e1b648788ca6518389f822f80017";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-aw0m3udnx7jphKF+7kL2lzrUdOrR5hHMbBFRR2jLXNU=";
    };
  };
  clash-premium-x86_64-linux = {
    pname = "clash-premium-x86_64-linux";
    version = "2022.08.26";
    src = fetchurl {
      url = "https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-2022.08.26.gz";
      sha256 = "sha256-F3Gn2b5zhgd+galkJIt5Hw2fDs9SGKPE7vxi+GRR3h0=";
    };
  };
  maxmind-geoip = {
    pname = "maxmind-geoip";
    version = "20221112";
    src = fetchurl {
      url = "https://github.com/Dreamacro/maxmind-geoip/releases/download/20221112/Country.mmdb";
      sha256 = "sha256-si/RzJvXbAcG7Wyv780Hwr+1oiWB+uvc2RYbnYpE0MA=";
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
