{
  cacert,
  fetchFromGitHub,
  lib,
  makeWrapper,
  nodejs_20,
  pnpm_9,
  stdenvNoCC,
}:
let
  pname = "open-code-review";
  version = "1.8.4";

  src = fetchFromGitHub {
    owner = "spencermarx";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-1bquZYsM4+OPFcs1qkXuXgKFCB2zE1FVtgXMFXM/Kvw=";
  };

  deployOut = stdenvNoCC.mkDerivation {
    pname = "${pname}-deploy";
    inherit version src;

    nativeBuildInputs = [
      cacert
      nodejs_20
      pnpm_9
    ];

    env.CI = "1";

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      export HOME="$TMPDIR"
      pnpm install --frozen-lockfile --ignore-scripts
      pnpm build:cli
      pnpm --filter @open-code-review/cli deploy --prod "$out"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-0Ef+MUm1+9IoALXcamgcqSbT7l5hmkzRkRn0WctDdx0=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "open-code-review";
  inherit version;

  nativeBuildInputs = [
    makeWrapper
    nodejs_20
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    local packageOut="$out/lib/node_modules/${pname}"

    mkdir -p "$out/bin"
    mkdir -p "$packageOut"
    cp -r ${deployOut}/. "$packageOut"/
    mkdir -p "$out/build/source/packages"
    ln -s ../../../lib/node_modules/${pname} "$out/build/source/packages/cli"

    makeWrapper ${lib.getExe nodejs_20} "$out/bin/ocr" \
      --add-flags "$packageOut/dist/index.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Customizable multi-agent code review CLI with web dashboard";
    homepage = "https://github.com/spencermarx/open-code-review";
    license = with licenses; [asl20];
    mainProgram = "ocr";
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [fromSource];
  };
}