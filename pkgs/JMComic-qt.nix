{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchPypi,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  libxcb,
  libxcb-cursor,
  libxcb-wm,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  ...
}:
let
  # commonx package (not in nixpkgs)
  commonx = python3Packages.buildPythonPackage rec {
    pname = "commonx";
    version = "0.6.39";
    format = "setuptools";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Lo/kHgeMkhUvlZO1qOeUoLdINU4rhz7mFjAGnXRad9U=";
    };

    doCheck = false;
  };

  # jmcomic package (not in nixpkgs)
  jmcomic = python3Packages.buildPythonPackage rec {
    pname = "jmcomic";
    version = "2.6.9";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Pfrtc6IQ3Ha7jZ1edwHgeTblEgBiSRrSeqShqskPcNc=";
    };

    build-system = with python3Packages; [ setuptools ];

    dependencies = with python3Packages; [
      curl-cffi
      pillow
      pycryptodome
      pyyaml
      commonx
    ];

    # Skip tests as they require network
    doCheck = false;

    pythonImportsCheck = [ "jmcomic" ];
  };
in
python3Packages.buildPythonApplication rec {
  pname = "JMComic-qt";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "tonquer";
    repo = "JMComic-qt";
    rev = "v${version}";
    hash = "sha256-ZeyJcCc2OdCeimOudDUaw1d/Bs5Q+5kE15W89G5SHGU=";
  };

  format = "other";

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    libxcb-cursor
    libxcb
    libxcb-wm
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
  ];

  propagatedBuildInputs = with python3Packages; [
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
    setuptools # provides distutils compatibility for Python 3.12+
    (httpx.overridePythonAttrs (
      finalAttrs: with finalAttrs; {
        dependencies = dependencies ++ (with optional-dependencies; http2 ++ socks);
      }
    ))
    jmcomic
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    # Create application directory
    mkdir -p $out/share/jmcomic-qt

    # Copy all Python source code and resources
    cp -r src/* $out/share/jmcomic-qt/
    cp -r lib $out/share/jmcomic-qt/

    # Create launcher script
    mkdir -p $out/bin
    cat > $out/bin/JMComic-qt <<EOF
    #!${python3Packages.python.interpreter}
    import sys
    import os

    # Set installation directory
    install_dir = "$out/share/jmcomic-qt"
    sys.path.insert(0, install_dir)
    os.chdir(install_dir)

    # Set library path for bundled libcurl-impersonate
    os.environ["LD_LIBRARY_PATH"] = os.path.join(install_dir, "lib", "linux") + ":" + os.environ.get("LD_LIBRARY_PATH", "")

    # Launch main program
    exec(compile(open(os.path.join(install_dir, "start.py")).read(), "start.py", "exec"))
    EOF
    chmod +x $out/bin/JMComic-qt

    # Wrap with Qt environment for PySide6 platform plugins
    wrapProgram $out/bin/JMComic-qt \
      --set QT_PLUGIN_PATH "${python3Packages.pyside6}/${python3Packages.python.sitePackages}/PySide6/Qt6/plugins" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libxcb-cursor libxcb ]}"

    # Install icon
    mkdir -p $out/share/pixmaps
    cp $src/res/icon/logo_round.png $out/share/pixmaps/JMComic.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "JMComic-qt";
      desktopName = "JMComic";
      comment = "禁漫天堂，18comic，使用qt实现的PC客户端";
      exec = "JMComic-qt %u";
      icon = "JMComic";
      terminal = false;
      type = "Application";
      categories = [
        "Graphics"
        "Network"
      ];
    })
  ];

  doCheck = false;

  meta = with lib; {
    description = "禁漫天堂，18comic，使用qt实现的PC客户端，支持Windows，Linux，MacOS";
    homepage = "https://github.com/tonquer/JMComic-qt";
    license = licenses.lgpl3;
    platforms = platforms.linux;
    mainProgram = "JMComic-qt";
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
