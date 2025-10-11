{
  fetchurl,
  appimageTools,
  lib,
  ...
}: let
  pname = "wechat-web-devtools-linux";
  version = "1.06.2504030-1";
  src = fetchurl {
    url = "https://github.com/msojocs/${pname}/releases/download/v${version}/WeChat_Dev_Tools_v${version}_x86_64_linux.AppImage";
    hash = "sha256-Wm2VMrynZ9l5nzTRRIrcXpsqKGGx3X+fgLbZCKU7Ysc=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
  appimageTools.wrapAppImage {
    inherit pname version;
    src = appimageContents;
    extraPkgs = pkgs:
      with pkgs; [
        xorg.libxshmfence
      ];
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${appimageContents}/io.github.msojocs.wechat_devtools.desktop $out/share/applications/
      mkdir -p $out/share/pixmaps
      cp ${appimageContents}/wechat-devtools.png $out/share/pixmaps/
      substituteInPlace $out/share/applications/io.github.msojocs.wechat_devtools.desktop --replace-fail 'Exec=bin/wechat-devtools' 'Exec=${pname}'
    '';
    meta = {
      description = "msojocs/wechat-web-devtools-linux: 适用于微信小程序的微信开发者工具 Linux移植版";
      homepage = "https://github.com/msojocs/wechat-web-devtools-linux";
      license = with lib.licenses; [
        mit
      ];
      platforms = lib.filter (p: lib.strings.hasSuffix "linux" p) lib.platforms.x86_64;
    };
  }
