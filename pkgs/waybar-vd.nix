{
  fetchurl,
  lib,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "waybar-vd";
  version = "0.1.1";
  dontBuild = true;
  dontUnpack = true;

  src = fetchurl {
    url = "https://github.com/givani30/${pname}/releases/download/v${version}/libwaybar_vd.so";
    hash = "sha256-MneSdnith7mpKmLToEsCWsDSED1/d/q/feoJi2iV5VY=";
  };

  installPhase = ''
    mkdir -p $out/lib
    cp -Rn $src $out/lib/libwaybar_vd.so
  '';

  meta = with lib; {
    description = "A high-performance CFFI module for Waybar that displays Hyprland virtual desktops with real-time updates and click handling.";
    homepage = "https://github.com/givani30/waybar-vd";
    license = with licenses; [mit];
    platforms = with platforms; (intersectLists x86_64 linux);
  };
}
