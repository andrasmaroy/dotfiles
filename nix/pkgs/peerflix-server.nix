{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  nodejs_22,
  makeWrapper,
  importNpmLock,
  ffmpeg,
}:

let
  version = "0.6.0";

  peerflixSrc = fetchFromGitHub {
    owner = "asapach";
    repo = "peerflix-server";
    rev = "79f437994f5789f99752169be2bc7fa12a52992b";
    hash = "sha256-P/3g60AAVhSIRdXpgOZl4JIgs9iOR+N/m5rjNOqNiJE=";
  };

  peerflixNpmTarball = fetchurl {
    url = "https://registry.npmjs.org/peerflix-server/-/peerflix-server-${version}.tgz";
    hash = "sha256-WyeXYOD5iH3+1Pl2fHFdtuELGzSPpb4OAEmfADlKEIo=";
  };

  peerflixNodeModules = importNpmLock.buildNodeModules {
    nodejs = nodejs_22;
    npmRoot = peerflixSrc;
  };
in
stdenv.mkDerivation {
  pname = "peerflix-server";
  inherit version;

  src = peerflixSrc;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/node_modules/peerflix-server
    cp -r server package.json $out/lib/node_modules/peerflix-server/

    tar -xzf ${peerflixNpmTarball} --strip-components=1 -C $out/lib/node_modules/peerflix-server package/dist

    cp -r ${peerflixNodeModules}/node_modules $out/lib/node_modules/peerflix-server/
    chmod -R +w $out/lib/node_modules/peerflix-server/node_modules

    mkdir -p $out/bin
    makeWrapper ${nodejs_22}/bin/node $out/bin/peerflix-server \
      --add-flags "$out/lib/node_modules/peerflix-server/server/bin.js" \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';
}
