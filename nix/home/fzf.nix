{ pkgs, ... }:
{
  # fzf: completion only (no key bindings), matching the old install flags. The
  # raw bash_profile sources ~/.fzf.bash; bash is not managed by programs.bash,
  # so provide the shim directly.
  home.packages = [ pkgs.fzf ];

  home.file.".fzf.bash".text = ''
    source ${pkgs.fzf}/share/fzf/completion.bash
  '';
}
