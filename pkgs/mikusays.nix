{
  fetchFromGitHub,
  rustPlatform,
  lib,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "mikusays";
  version = "0.1.3";
  src = fetchFromGitHub {
    owner = "xxanqw";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-KtYdnFOpWseRGm6zLeFfBYfI2IV2m8AaqcUTV7xgCeg=";
  };
  cargoHash = "sha256-B3kguD0kJPNfOz20nwrRG+TlovxNoXvUhCZV+CCRbdg=";
  meta = {
    description = "A `cowsay` clone with Hatsune Miku ASCII art and speech bubbles.";
    homepage = "https://github.com/xxanqw/mikusays";
    platforms = lib.platforms.windows ++ lib.platforms.linux ++ lib.platforms.darwin;
    license = lib.licenses.mit;
  };
})
