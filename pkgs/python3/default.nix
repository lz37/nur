{pkgs}:
with pkgs.lib;
  mapAttrs' (name: value: nameValuePair ("python3-" + name) value) rec {
    waifu2x-vulkan = pkgs.callPackage ./waifu2x-vulkan.nix {};
    commonx = pkgs.callPackage ./commonx.nix {};
    jmcomic = pkgs.callPackage ./jmcomic.nix {inherit commonx;};
  }
