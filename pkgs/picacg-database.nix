{
  stdenv,
  fetchurl,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "picacg-database";
  version = "1.5.3";
  src = fetchurl {
    url = "https://github.com/bika-robot/${pname}/releases/download/v${version}/book.db";
    hash = "sha256-Qt/8D8ahKvYCC8+G+89yZCFTe99w/Oc+ZekX968e3oo=";
  };
  dontBuild = true;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/${pname}
    cp -r $src $out/share/${pname}/book.db
    runHook postInstall
  '';
  meta = with lib; {
    description = "database of picacg - 使用百度翻译Api";
    homepage = "https://github.com/bika-robot/picacg-database";
    platforms = with platforms; (intersectLists x86_64 linux);
    license = with licenses; [mit];
    mainProgram = pname;
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
}
