{
  stdenv,
  lib,
  fetchFromGitHub,
  pkgs,
  python3,
  fetchurl,
  ...
}: let
  pname = "picacg-qt";
  version = "1.5.2";
  python =
    python3.withPackages
    (ps:
      with ps; [
        pyinstaller
        pyside6
        websocket-client
        pillow
        pysocks
        natsort
        webdavclient3
        tqdm
        pysmb
        lxml
        (httpx.overridePythonAttrs (finalAttrs:
          with finalAttrs; {
            dependencies = dependencies ++ (with optional-dependencies; http2 ++ socks);
          }))
        ((import ./python3 {inherit pkgs;}).python3-waifu2x-vulkan.override
          {inherit buildPythonPackage;})
      ]);
  picacgDatabase = stdenv.mkDerivation rec {
    pname = "picacg-database";
    version = "1.5.3";
    src = fetchurl {
      url = "https://github.com/bika-robot/${pname}/releases/download/v${version}/book.db";
      hash = "sha256-Qt/8D8ahKvYCC8+G+89yZCFTe99w/Oc+ZekX968e3oo=";
    };
    dontBuild = true;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/${pname}
      cp -r $src $out/share/${pname}/book.db
    '';
  };
  runtimeDep = with pkgs; ([
      vulkan-loader
    ]
    ++ (
      if (lib.versionAtLeast lib.version "25.11")
      then [libxcb-util libxcb]
      else [xorg.libxcb]
    ));
in
  stdenv.mkDerivation rec {
    inherit pname version;
    src = fetchFromGitHub {
      owner = "tonquer";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-tsIEfcUsI3RFSmFf2uXgQpbjHOIOqhupgZmRQdtoDoU=";
    };
    nativeBuildInputs = with pkgs; [
      fuse
      makeWrapper
      python
    ];
    buildInputs = runtimeDep ++ [picacgDatabase];
    buildPhase = ''
      runHook preBuild
      pyinstaller -w src/start.py
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
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeDep} \
        --run 'if [ ! -d ~/.picacg/db ];then mkdir -p ~/.picacg/db; echo "mkdir db";fi' \
        --run 'if [ ! -d ~/.picacg/data ];then mkdir -p ~/.picacg/data; echo "mkdir data";fi' \
        --run 'if [ ! -f ~/.picacg/version ];then touch ~/.picacg/db/version; echo "mkdir version";fi' \
        --run 'if [ ! -f ~/.picacg/db/book.db ] || [ "`cat ~/.picacg/db/version`" != "${picacgDatabase.version}" ] ; then cp -f ${picacgDatabase}/share/${picacgDatabase.pname}/book.db ~/.picacg/db/;echo "${picacgDatabase.version}" > ~/.picacg/db/version;echo "copy db";fi'
      runHook postInstall
    '';
    meta = with lib; {
      description = "tonquer/picacg-qt: 哔咔漫画, PicACG comic PC client(Windows, Linux, MacOS)";
      homepage = "https://github.com/tonquer/picacg-qt";
      platforms = with platforms; (intersectLists x86_64 linux);
      license = with licenses; [lgpl3];
      mainProgram = pname;
      sourceProvenance = with sourceTypes; [fromSource];
    };
  }
