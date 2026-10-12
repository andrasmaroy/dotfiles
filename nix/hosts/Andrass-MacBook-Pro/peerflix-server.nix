{ pkgs, ... }:

let
  version = "0.6.0";

  peerflixSrc = pkgs.fetchFromGitHub {
    owner = "asapach";
    repo = "peerflix-server";
    rev = "79f437994f5789f99752169be2bc7fa12a52992b";
    hash = "sha256-P/3g60AAVhSIRdXpgOZl4JIgs9iOR+N/m5rjNOqNiJE=";
  };

  peerflixNpmTarball = pkgs.fetchurl {
    url = "https://registry.npmjs.org/peerflix-server/-/peerflix-server-${version}.tgz";
    hash = "sha256-WyeXYOD5iH3+1Pl2fHFdtuELGzSPpb4OAEmfADlKEIo=";
  };

  peerflixNodeModules = pkgs.importNpmLock.buildNodeModules {
    nodejs = pkgs.nodejs_22;
    npmRoot = peerflixSrc;
  };

  peerflix-server-native = pkgs.stdenv.mkDerivation {
    pname = "peerflix-server";
    version = "${version}";

    src = peerflixSrc;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/lib/node_modules/peerflix-server
      cp -r server package.json $out/lib/node_modules/peerflix-server/

      tar -xzf ${peerflixNpmTarball} --strip-components=1 -C $out/lib/node_modules/peerflix-server package/dist

      cp -r ${peerflixNodeModules}/node_modules $out/lib/node_modules/peerflix-server/
      chmod -R +w $out/lib/node_modules/peerflix-server/node_modules

      mkdir -p $out/bin
      makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/peerflix-server \
        --add-flags "$out/lib/node_modules/peerflix-server/server/bin.js" \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ffmpeg ]}
    '';
  };
in
{
  environment.systemPackages = [ peerflix-server-native ];

  launchd.user.agents.peerflix-server = {
    script = ''
      mkdir -p /tmp/torrent-stream
      touch /tmp/peerflix-server.out.log /tmp/peerflix-server.err.log
      exec ${peerflix-server-native}/bin/peerflix-server
    '';
    serviceConfig = {
      WorkingDirectory = "${peerflix-server-native}/lib/node_modules/peerflix-server";
      EnvironmentVariables = {
        "HOME" = "/tmp/torrent-stream";
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/peerflix-server.out.log";
      StandardErrorPath = "/tmp/peerflix-server.err.log";
    };
  };
}
