{
  fetchurl,
  lib,
  python3,
  ...
}:
with python3.pkgs;
  buildPythonPackage rec {
    pname = "waifu2x-vulkan";
    version = "1.1.6";
    format = "wheel";
    src = fetchurl {
      url = "https://github.com/tonquer/${pname}/releases/download/v${version}/sr_ncnn_vulkan-1.2.0-cp37-abi3-linux_x86_64.whl";
      hash = "sha256-Sl4sHDA7CcgmYaKn5OMbDZg/vZKlFi0ByxQdXwxLxEQ=";
    };
    meta = with lib; {
      description = "tonquer/sr-ncnn-vulkan: waifu2x-ncnn-vulkan-python, use nihui/waifu2x-ncnn-vulkan";
      homepage = "https://github.com/tonquer/sr-ncnn-vulkan";
      platforms = with platforms; (intersectLists x86_64 linux);
      license = with licenses; [mit];
      sourceProvenance = with sourceTypes; [binaryBytecode];
    };
  }
