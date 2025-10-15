# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  python3-pkgs = import ./pkgs/python3 {inherit pkgs;};
in (rec {
    # The `lib`, `modules`, and `overlays` names are special
    lib = import ./lib {inherit pkgs;}; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays
    fortune-mod-zh = pkgs.callPackage ./pkgs/fortune-mod-zh.nix {};
    JMComic-qt = pkgs.callPackage ./pkgs/JMComic-qt.nix {inherit (python3-pkgs) python3-waifu2x-vulkan python3-jmcomic;};
    picacg-database = pkgs.callPackage ./pkgs/picacg-database.nix {};
    picacg-qt = pkgs.callPackage ./pkgs/picacg-qt.nix {
      inherit (python3-pkgs) python3-waifu2x-vulkan;
      inherit picacg-database;
    };
    mikusays = pkgs.callPackage ./pkgs/mikusays.nix {};
    sddm-eucalyptus-drop = pkgs.callPackage ./pkgs/sddm-eucalyptus-drop.nix {};
    wechat-web-devtools-linux = pkgs.callPackage ./pkgs/wechat-web-devtools-linux.nix {};
    zsh-url-highlighter = pkgs.callPackage ./pkgs/zsh-url-highlighter.nix {};
    waybar-vd = pkgs.callPackage ./pkgs/waybar-vd {};
  }
  // python3-pkgs)
