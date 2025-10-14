{
  pkgs,
  stdenv,
  lib,
  ...
}: let
  version = "1.0.0";
  pname = "zsh-url-highlighter";
in
  stdenv.mkDerivation {
    inherit pname version;
    src = pkgs.fetchFromGitHub {
      owner = "ascii-soup";
      repo = "zsh-url-highlighter";
      rev = version;
      hash = "sha256-NRlAKHaoXPKrAK+sz09Cyvj8pvnT85Ubh0Hrk4DmuxE=";
    };

    strictDeps = true;
    buildInputs = [pkgs.zsh];
    installPhase = ''
      mkdir -p $out/share/zsh-syntax-highlighting/highlighters/
      cp -r url $out/share/zsh-syntax-highlighting/highlighters/
    '';

    meta = with lib; {
      description = "A plugin for zsh-syntax-highlighting that turns URLs green if they respond with a \" good \"** status, and red otherwise. Useful for checking URL typos.";
      homepage = "https://github.com/ascii-soup/zsh-url-highlighter";
      platforms = pkgs.zsh.meta.platforms;
      sourceProvenance = with sourceTypes; [fromSource];
    };
  }
