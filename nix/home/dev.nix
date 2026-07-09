{ pkgs, ... }:
{
  # Development toolchain (was roles/packages/tasks/dev/*). None of these ships
  # a dotfile of its own except flake8.
  home.packages = with pkgs; [
    # javascript
    nodejs # was node
    typescript
    # linters
    shellcheck
    # python
    black
    python3Packages.flake8
    python3Packages.isort
    pipenv
    python3Packages.setuptools # was python-setuptools
    python3Packages.virtualenvwrapper
    python3 # was python
    # tools
    gh
    kubernetes-helm # was helm
    kubectl
  ];

  # flake8 config (was symlinked to ~/.config/flake8 by the python role).
  home.file.".config/flake8".source = ../../config/flake8;
}
