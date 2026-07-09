{ pkgs, ... }:
{
  # The "applications" layer: GUI apps and Mac App Store apps stay on Homebrew
  # (nixpkgs cask support on darwin is weak), but nix-darwin owns them
  # declaratively. Ported 1:1 from the Ansible homebrew_cask / mas / brew tasks.
  # Requires an existing Homebrew install (set up at bootstrap); nothing here
  # runs until `darwin-rebuild switch`.

  # The `mas` CLI that drives homebrew.masApps below.
  environment.systemPackages = [ pkgs.mas ];

  homebrew = {
    enable = true;

    # Homebrew-only formulae with no nixpkgs equivalent (shell completions).
    # Prune candidates once native completion lands (see plan).
    brews = [
      "brew-cask-completion"
      "docker-completion"
      "pip-completion"
    ];

    # NOTE: the Ansible config passed install_options 'appdir=~/Applications'
    # for the comm/media/tools casks. nix-darwin's homebrew module has no
    # per-cask appdir option, so these install to /Applications.
    casks = [
      "appcleaner"
      "balenaetcher"
      "beeper"
      "disk-inventory-x"
      "docker"
      "firefox"
      "google-chrome"
      "itsycal"
      "jordanbaird-ice"
      "keepingyouawake"
      "linearmouse"
      "monitorcontrol"
      "p4v"
      "raspberry-pi-imager"
      "rectangle"
      "vlc"
    ];

    # Mac App Store apps (needs the `mas` CLI, installed above).
    masApps = {
      Bitwarden = 1352778147;
    };
  };

  # The Arduino toolchain (osx-cross/avr tap, avr-binutils/avr-gcc, arduino +
  # teensy casks) was disabled in the Ansible config (commented import) and
  # stays disabled here.
}
