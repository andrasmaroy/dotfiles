{ pkgs, ... }:
{
  # fzf, ported from roles/packages/tasks/shell-utilities/fzf.yml. The Ansible
  # install ran with --completion --no-key-bindings, and the raw bash_profile
  # sources ~/.fzf.bash. bash is not managed by programs.bash, so HM's bash
  # integration is off and a shim provides completion (no key bindings) from
  # the nixpkgs fzf package.
  programs.fzf = {
    enable = true;
    enableBashIntegration = false;
  };

  home.file.".fzf.bash".text = ''
    source ${pkgs.fzf}/share/fzf/completion.bash
  '';
}
