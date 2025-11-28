{
  fetchFromGitHub,
  rustPlatform,
  lib,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "mikusays";
  version = "0.1.4";
  src = fetchFromGitHub {
    owner = "xxanqw";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-0Q5htVZb5axRUBQio8B2TkaehMTjhkEM0T8qlpmuo6w=";
  };

  postPatch = ''
    substituteInPlace tests/integration_tests.rs \
      --replace-fail 'Command::new("target/debug/mikusays")' 'Command::new(env!("CARGO_BIN_EXE_mikusays"))'
  '';

  cargoHash = "sha256-X1jGdiDyKgeu+O/rhv5NEr9yr9X6C7Rng/+XdnM9s8A=";

  # 允许使用不稳定的 Rust 特性
  RUSTC_BOOTSTRAP = 1;

  meta = with lib; {
    description = "A `cowsay` clone with Hatsune Miku ASCII art and speech bubbles.";
    homepage = "https://github.com/xxanqw/mikusays";
    platforms = with platforms; (windows ++ linux ++ darwin);
    license = with licenses; [mit];
    mainProgram = pname;
    sourceProvenance = with sourceTypes; [fromSource];
  };
})
