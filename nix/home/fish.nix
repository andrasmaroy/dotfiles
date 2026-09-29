{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    fish
    fishPlugins.done
    # fishPlugins.fzf-fish
    fishPlugins.puffer
  ];

  programs.fish.plugins = [
    {
      name = "async-prompt";
      src = pkgs.fetchFromGitHub {
        owner = "andrasmaroy";
        repo = "fish-async-prompt";
        rev = "41c7a16fec0339ba9e55ea66183fda8504e290fa";
        hash = "sha256-u+E5jd2IvBB0C6cXeP1o0SqKm+SXdCfxbGmYZiPXkyg=";
      };
    }
  ];
}
