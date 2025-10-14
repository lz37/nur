{
  lib,
  stdenv,
  fetchFromGitHub,
  pkgs,
  fetchPypi,
  python3,
  fetchurl,
  ...
}: let
  python =
    python3.withPackages
    (ps:
      with ps; [
        pyinstaller
        pyside6
        pillow
        lxml
        pycryptodomex
        pysocks
        natsort
        curl-cffi
        webdavclient3
        tqdm
        pysmb
        beautifulsoup4
        (httpx.overridePythonAttrs (finalAttrs:
          with finalAttrs; {
            dependencies = dependencies ++ (with optional-dependencies; http2 ++ socks);
          }))
        (buildPythonPackage rec {
          pname = "jmcomic";
          version = "2.6.9";
          pyproject = true;
          build-system = [setuptools];
          src = fetchPypi {
            inherit pname version;
            hash = "sha256-Pfrtc6IQ3Ha7jZ1edwHgeTblEgBiSRrSeqShqskPcNc=";
          };
          propagatedBuildInputs = [
            curl-cffi
            pillow
            pycryptodome
            pyyaml
            (buildPythonPackage rec {
              pname = "commonx";
              version = "0.6.39";
              format = "setuptools";
              src = fetchPypi {
                inherit pname version;
                hash = "sha256-Lo/kHgeMkhUvlZO1qOeUoLdINU4rhz7mFjAGnXRad9U=";
              };
              # Package name is commonx but import name is common
              doCheck = false;
            })
          ];
          # Skip runtime deps check because commonx package name != import name (common)
          dontCheckRuntimeDeps = true;
          pythonImportsCheck = ["jmcomic"];
        })
        (buildPythonPackage rec {
          pname = "waifu2x-vulkan";
          version = "1.1.6";
          format = "wheel";
          src = fetchurl {
            url = "https://github.com/tonquer/${pname}/releases/download/v${version}/sr_ncnn_vulkan-1.2.0-cp37-abi3-linux_x86_64.whl";
            hash = "sha256-Sl4sHDA7CcgmYaKn5OMbDZg/vZKlFi0ByxQdXwxLxEQ=";
          };
        })
      ]);
in
  stdenv.mkDerivation rec {
    pname = "JMComic-qt";
    version = "1.2.9";
    src = fetchFromGitHub {
      owner = "tonquer";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-cvDdA5xewawO7ccs3Zv1xfTW9zHImnu+xLUKvq3Fpns=";
    };
    nativeBuildInputs = with pkgs; [
      fuse
      makeWrapper
      python
    ];
    buildInputs = with pkgs; [
      libxcb-util
      vulkan-loader
    ];
    buildPhase = ''
      runHook preBuild
      pyinstaller --hidden-import=_cffi_backend --collect-data curl_cffi --add-data "./lib/linux/*:."  -w src/start.py
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share
      cp -r dist/start $out/share/${pname}
      mkdir -p $out/bin
      ln -s $out/share/${pname}/start $out/bin/${pname}
      mkdir -p $out/share/applications
      cp $src/res/appimage/*.desktop $out/share/applications/${pname}.desktop
      mkdir -p $out/share/pixmaps
      cp $src/res/icon/logo_round.png $out/share/pixmaps/${pname}.png
      wrapProgram $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
      runHook postInstall
    '';
    meta = with lib; {
      description = "tonquer/JMComic-qt: 禁漫天堂，18comic，使用qt实现的PC客户端，支持Windows，Linux，MacOS";
      homepage = "https://github.com/tonquer/JMComic-qt";
      platforms = with platforms; (intersectLists x86_64 linux);
      license = with licenses; [lgpl3];
      mainProgram = pname;
      sourceProvenance = with sourceTypes; [fromSource];
    };
  }
