{
  lib,
  stdenv,
  fetchFromGitHub,
  pkgs,
  python3,
  python3-waifu2x-vulkan,
  python3-jmcomic,
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
        python3-jmcomic
        (python3-waifu2x-vulkan.override
          {inherit python3;})
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
    buildInputs = with pkgs; ([
        vulkan-loader
      ]
      ++ (
        if (pkgs ? libxcb-util)
        then [libxcb-util libxcb]
        else [xorg.libxcb]
      ));
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
