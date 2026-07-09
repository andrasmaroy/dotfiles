{ pkgs, ... }:
{
  # git: raw config + globals + executable helper + hook template dir. Identity
  # (name/email/signingkey) comes from the ~/.dotoverrides/gitconfig include,
  # not the committed config. delta is the pager.
  home.packages = with pkgs; [
    git
    delta # was git-delta
  ];

  home.file = {
    ".gitconfig".source = ../../config/git/config;
    ".gitignore_global".source = ../../config/git/gitignore_global;
    ".gitattributes_global".source = ../../config/git/gitattributes_global;
    ".githelpers".source = ../../config/git/githelpers;
    ".git_template".source = ../../config/git/git_template;
  };
}
