{
  lib,
  stdenvNoCC,
  fetchurl,
  fontforge,
  nerd-font-patcher,
}:

stdenvNoCC.mkDerivation {
  pname = "menlo-nerd-font";
  version = "unstable";

  src = fetchurl {
    url = "file:///System/Library/Fonts/Menlo.ttc";
    sha256 = "3CVuCznCpv7JRxKdQh/vQbi0KfWPm25dGxSMh/d1wfY=";
  };

  unpackPhase = ''
    cp $src Menlo.ttc
    chmod +w Menlo.ttc
  '';

  nativeBuildInputs = [
    fontforge
    nerd-font-patcher
  ];

  buildPhase = ''
    runHook preBuild
    nerd-font-patcher Menlo.ttc
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm444 'Menlo Nerd Font.ttc' $out/share/fonts/truetype/MenloNerdFont.ttc
    runHook postInstall
  '';

  meta = {
    description = "Menlo patched with Nerd Font glyphs";
    homepage = "https://github.com/indirect/menlo-nerd-font";
    platforms = lib.platforms.darwin;
  };
}
