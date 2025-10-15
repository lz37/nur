{
  fetchPypi,
  lib,
  python3,
  ...
}:
with python3.pkgs;
buildPythonPackage rec {
  pname = "commonx";
  version = "0.6.39";
  format = "setuptools";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Lo/kHgeMkhUvlZO1qOeUoLdINU4rhz7mFjAGnXRad9U=";
  };
  # Package name is commonx but import name is common
  doCheck = false;
  meta = with lib; {
    description = "python common toolkit";
    homepage = "https://github.com/hect0x7/common";
    platforms = with platforms; all;
    license = with licenses; [mit];
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
}
