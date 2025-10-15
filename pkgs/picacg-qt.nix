{
  stdenv,
  lib,
  fetchFromGitHub,
  python3,
  python3-waifu2x-vulkan,
  picacg-database,
  fuse,
  makeWrapper,
  xorg,
  libxcb-util ? null,
  libxcb ? xorg.libxcb,
  vulkan-loader,
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
        (python3-waifu2x-vulkan.override
          {inherit python3;})
      ]);
  runtimeDep =
    [
      vulkan-loader
      libxcb
    ]
    ++ (
      lib.optional (libxcb-util != null) libxcb-util
    );
in
  stdenv.mkDerivation rec {
    inherit pname version;
    src = fetchFromGitHub {
      owner = "tonquer";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-tsIEfcUsI3RFSmFf2uXgQpbjHOIOqhupgZmRQdtoDoU=";
    };
    nativeBuildInputs = [
      fuse
      makeWrapper
      python
    ];
    buildInputs = runtimeDep ++ [picacg-database];
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
        --run 'if [ ! -f ~/.picacg/db/book.db ] || [ "`cat ~/.picacg/db/version`" != "${picacg-database.version}" ] ; then cp -f ${picacg-database}/share/${picacg-database.pname}/book.db ~/.picacg/db/;echo "${picacg-database.version}" > ~/.picacg/db/version;echo "copy db";fi'
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-fail PicACG ${pname}
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
