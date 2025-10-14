{pkgs}:
with pkgs.lib;
  mapAttrs' (name: value: nameValuePair ("python3-" + name) (value {inherit (pkgs.python3.pkgs) buildPythonPackage;})) {
    waifu2x-vulkan = pkgs.callPackage ./waifu2x-vulkan.nix;
  }
