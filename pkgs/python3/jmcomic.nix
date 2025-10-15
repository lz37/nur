{
  fetchPypi,
  lib,
  commonx,
  python3,
  ...
}:
with python3.pkgs;
  buildPythonPackage rec {
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
      commonx
    ];
    # Skip runtime deps check because commonx package name != import name (common)
    dontCheckRuntimeDeps = true;
    pythonImportsCheck = ["jmcomic"];
    meta = with lib; {
      description = "Python API for JMComic | 提供Python API访问禁漫天堂，同时支持网页端和移动端 | 禁漫天堂GitHub Actions下载器🚀 - hect0x7/JMComic-Crawler-Python";
      homepage = "https://github.com/hect0x7/JMComic-Crawler-Python";
      platforms = with platforms; all;
      license = with licenses; [mit];
      sourceProvenance = with sourceTypes; [fromSource];
    };
  }
