{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
  ...
}:
let
  # picacg database file
  picacg-database = stdenv.mkDerivation rec {
    pname = "picacg-database";
    version = "1.5.4";
    src = fetchurl {
      url = "https://github.com/bika-robot/picacg-database/releases/download/v${version}/book.db";
      hash = "sha256-veiuykIRd8VbQbEnbymmBu+bj3C8tprk4qHJiwBHC/A=";
    };
    dontBuild = true;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/picacg-database
      cp $src $out/share/picacg-database/book.db
    '';
  };
in
python3Packages.buildPythonApplication rec {
  pname = "picacg-qt";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "tonquer";
    repo = "picacg-qt";
    rev = "v${version}";
    hash = "sha256-MCPQcSCEHI//YOsEbq8GWcN8U2nIjewryj7AUcl3PaA=";
  };

  format = "other";

  nativeBuildInputs = [
    copyDesktopItems
  ];

  propagatedBuildInputs = with python3Packages; [
    pyside6
    websocket-client
    pillow
    pysocks
    natsort
    webdavclient3
    tqdm
    pysmb
    lxml
    setuptools # provides distutils compatibility for Python 3.12+
    (httpx.overridePythonAttrs (
      finalAttrs: with finalAttrs; {
        dependencies = dependencies ++ (with optional-dependencies; http2 ++ socks);
      }
    ))
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    # Create application directory
    mkdir -p $out/share/picacg-qt

    # Copy all Python source code and resources
    cp -r src/* $out/share/picacg-qt/

    # Create launcher script
    mkdir -p $out/bin
    cat > $out/bin/picacg-qt <<EOF
    #!${python3Packages.python.interpreter}
    import sys
    import os
    import shutil
    import stat

    # Set installation directory
    install_dir = "$out/share/picacg-qt"
    sys.path.insert(0, install_dir)
    os.chdir(install_dir)

    # Ensure user data directories exist
    picacg_dir = os.path.expanduser("~/.picacg")
    db_dir = os.path.join(picacg_dir, "db")
    data_dir = os.path.join(picacg_dir, "data")
    version_file = os.path.join(picacg_dir, "db", "version")

    os.makedirs(db_dir, exist_ok=True)
    os.makedirs(data_dir, exist_ok=True)

    # Copy database if needed
    db_src = "${picacg-database}/share/picacg-database/book.db"
    db_dest = os.path.join(db_dir, "book.db")
    db_version = "${picacg-database.version}"

    current_version = ""
    if os.path.exists(version_file):
        with open(version_file, "r") as f:
            current_version = f.read().strip()

    if not os.path.exists(db_dest) or current_version != db_version:
        shutil.copy(db_src, db_dest)
        with open(version_file, "w") as f:
            f.write(db_version)

    # Always ensure database is writable (fix stale permissions from Nix store copy)
    if os.path.exists(db_dest):
        current_mode = os.stat(db_dest).st_mode
        if not (current_mode & stat.S_IWUSR):
            os.chmod(db_dest, stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH)
    # Launch main program
    exec(compile(open(os.path.join(install_dir, "start.py")).read(), "start.py", "exec"))
    EOF
    chmod +x $out/bin/picacg-qt

    # Install icon
    mkdir -p $out/share/pixmaps
    cp $src/res/icon/logo_round.png $out/share/pixmaps/PicACG.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "picacg-qt";
      desktopName = "PicACG";
      comment = "哔咔漫画，PicACG comic PC client";
      exec = "picacg-qt %u";
      icon = "PicACG";
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
    description = "哔咔漫画，PicACG comic PC client (Windows, Linux, MacOS)";
    homepage = "https://github.com/tonquer/picacg-qt";
    license = licenses.lgpl3;
    platforms = platforms.linux;
    mainProgram = "picacg-qt";
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
