# Plan: Migrate dotfiles from Ansible → Nix

**Status:** Planned
**Scope:** Full replacement of the Ansible-based setup with a flake-based
`nix-darwin` + `home-manager` configuration.
**Branch:** `ansible-to-nix` — all work for this plan lands on this branch
(named after the plan file), never directly on `master`.

---

## Goal

Replace the current Ansible playbook (`site.yml` + `roles/`) — bootstrapped via
`pipenv`/`ansible-playbook` — with a reproducible, pinned, flake-based Nix
setup. At the end, Ansible is removed and the machine is provisioned with a
single `darwin-rebuild switch`.

## Decisions

| Topic | Decision | Notes |
|-------|----------|-------|
| Architecture | **`nix-darwin` + `home-manager`, flake-based** (pinned via `flake.lock`) | nix-darwin owns system-level config; home-manager owns the user environment. |
| GUI apps / Mac App Store | **Declarative Homebrew via nix-darwin's `homebrew` module** | Casks + `mas` managed declaratively; nixpkgs cask support on darwin is weak, so brew stays but Nix owns it. |
| Dotfiles | **Keep config files verbatim; home-manager symlinks them**, using native `programs.*` modules only where a config is *fully* expressible | Editable-in-repo raw files use `mkOutOfStoreSymlink`. See classification table below. |
| Migration scope | **Full replacement** — port everything, verify parity, then remove Ansible | Built on the `ansible-to-nix` branch first (see CI). |

### Assumptions (correct these if wrong)

- **macOS-only.** Linux vestiges (`bash_profile`/`tmux-linux.conf` branches,
  `bin/Darwin/linux`, `Gnome-Terminal/`) remain as inert files.
- **Apple Silicon** (`aarch64-darwin`, `/opt/homebrew`). Single host to start,
  structured so a second host is a small addition.
- The `profile/` employer bundles stay disabled (ported as commented stubs).

---

## Target repo layout

```
flake.nix                 # inputs: nixpkgs, nix-darwin, home-manager; darwinConfigurations.<host>; formatter
flake.lock
hosts/
  <hostname>/default.nix  # host-specific: hostname, user, which modules on
darwin/
  default.nix             # nix settings, /etc/shells, primary user + login shell
  homebrew.nix            # taps + casks + masApps (was packages/applications + mas)
  defaults.nix            # system.defaults.{dock,finder,trackpad,NSGlobalDomain,...}
  activation.nix          # firewall (socketfilterfw), caps-lock→esc per-keyboard remap
home/
  default.nix             # imports; home.packages (CLI); raw-symlink home.file block
  git.nix                 # programs.git  (+ home.file for githelpers, git_template/)
  ssh.nix                 # programs.ssh  (+ home.activation for ~/.ssh dirs & perms)
  bat.nix                 # programs.bat  (theme + PlainTasks syntax fetched at build via fetchurl)
  fzf.nix                 # programs.fzf
  # NOTE: no bash.nix / tmux.nix / vim.nix module — those are pure raw symlinks
files/                    # raw config files, moved out of roles/*/files
  bash/ tmux/ vim/ git/ bat/ ...
bin/ dotoverrides/        # unchanged; symlinked via home.file (mkOutOfStoreSymlink)
docs/plans/               # this plan and future modernization plans
```

---

## Package mapping

- **CLI formulae → `home.packages` (nixpkgs):** bash, git, git-delta, tmux,
  vim, ctags, node, typescript, shellcheck, black, flake8, isort, pipenv,
  python, gh, helm, kubectl, bandwhich, coreutils, fd, gnused, gnugrep, gnupg,
  jq, openssl, ripgrep, tree, watch, wget, bat, fzf, mas.
- **Casks → `homebrew.casks` (nix-darwin):** firefox, google-chrome, beeper,
  vlc, appcleaner, balenaetcher, disk-inventory-x, itsycal, jordanbaird-ice,
  keepingyouawake, linearmouse, monitorcontrol, raspberry-pi-imager, rectangle,
  docker, p4v.
- **MAS → `homebrew.masApps`:** Bitwarden `1352778147`.
- **Drop / replace (verify before removing):** `reattach-to-user-namespace`
  (unneeded on modern macOS tmux), completion formulae (`bash-completion@2`,
  `pip-completion`, `brew-cask-completion`) → native home-manager completion,
  `terminal-notifier`, `virtualenvwrapper`/`python-setuptools`/`cmake`
  evaluated per actual need.

---

## Config / dotfile classification

Determined by reading each file. A config is handled by a **home-manager
native module** only when it is *fully* expressible there; otherwise it stays a
**raw symlink** (`mkOutOfStoreSymlink`, editable in the working tree).

| Config | Handling | Why |
|--------|----------|-----|
| **git** (`gitconfig`, `gitignore_global`, `gitattributes_global`) | **native** — `programs.git` (`aliases`, `delta`, `includes`, `ignores`, `attributes`, `extraConfig`, `init.templateDir`) | 100% declarative key/values |
| **ssh** (`config`) | **native** — `programs.ssh` (`matchBlocks`, `includes`, `extraOptions` for crypto policy) | fully declarative |
| **bat** | **native** — `programs.bat` (`themes`, `syntaxes`, `config`) | replaces imperative download + cache rebuild |
| **fzf** | **native** — `programs.fzf` | replaces `install` script |
| **`githelpers`** | **raw symlink** | executable bash script sourced by git aliases (`. ~/.githelpers`) |
| **`git_template/`** hooks | **raw symlink** (dir) | executable hook files; only referenced via `init.templateDir` |
| **`bash_profile`, `bash_prompt`, `bash_colors`, `inputrc`** | **raw symlink** | ~400 lines of functions/`PROMPT_COMMAND`/`_setup_env`; files source each other by literal `~/.` path; only expressible as verbatim `initExtra`/`extraConfig` |
| **tmux** (`tmux.conf`, `tmux-osx.conf`, `tmux-linux.conf`) | **raw symlink** | version/platform `if-shell` logic + file sourcing + TPM bootstrap |
| **vim** (`vimrc`, `gvimrc`, `vim/`, `ctags`, `ycm_global_extra_conf`) | **raw symlink** | submodule plugins + compiled YouCompleteMe + copilot |
| **`bin/`, `dotoverrides`** | **raw symlink** | opaque scripts / external submodule |

### Consequences

- **Do not enable `programs.bash`** — it would try to own
  `~/.bash_profile`/`~/.bashrc` and conflict with the raw symlinks. Login shell
  + `/etc/shells` are handled by nix-darwin instead.
- **git is hybrid:** `gitconfig` content → `programs.git`; `githelpers` and
  `git_template/` stay raw files that `programs.git` references
  (`init.templateDir = ~/.git_template`; aliases keep `. ~/.githelpers`). The
  `~/.dotoverrides/gitconfig` include → `programs.git.includes`.
- **bat theme/syntax are fetched at build** via `pkgs.fetchurl`, pinned by
  upstream commit + content hash (fixed-output derivations), instead of
  `get_url` at apply time — declarative *and* nothing from other repos is
  committed to this (public) repo. `programs.bat` rebuilds the cache. (The
  PlainTasks syntax is patched in a `runCommand` to add the uppercase `TODO`
  extension the old `lineinfile` step added.)
- **ssh:** `programs.ssh` writes `~/.ssh/config`; the directory scaffolding
  (`cm_sockets` 0700, `config.d`, `keys/personal`, `keys/work`) still needs a
  `home.activation` step. Crypto subtraction lists (`Ciphers -3des-cbc,…`) go
  through `extraOptions` verbatim.

---

## macOS defaults mapping

- **Directly expressible in `system.defaults`:** dock, finder, trackpad,
  screensaver, control-center clock, `NSGlobalDomain` (autocorrect/quotes/
  dashes, keyboard nav), misc (screenshot shadow, LSQuarantine, ad
  personalization, volume feedback, notification previews). Covers the majority
  of `dock.yml`/`finder.yml`/`trackpad.yml`/`screensaver.yml`/
  `controlcentre.yml`/`misc.yml`.
- **`system.defaults.CustomUserPreferences`** for keys without first-class
  options (some `com.apple.ncprefs`, per-currentHost trackpad keys, Terminal.app
  settings).
- **`system.activationScripts`** (faithful ports of the imperative bits):
  - **Firewall:** `socketfilterfw` enable + disable allow-signed (was
    `firewall.yml`).
  - **Caps-lock → Escape:** per-keyboard product-ID remap (was `keyboard.yml`)
    — cannot be pure declarative.
  - Terminal.app profile import (`Terminal_app/andrasmaroy.terminal`) via
    `open`/`defaults import`, or leave manual (noted).

---

## Bootstrap rewrite (`bootstrap.sh`)

1. Xcode CLT + Rosetta (unchanged, macOS).
2. SSH key gen + GitHub prompt (unchanged).
3. Clone repo `--recurse-submodules` (unchanged).
4. Install Nix (Determinate Systems installer; flakes enabled).
5. First apply: `nix run nix-darwin -- switch --flake .#<host>`; thereafter
   `darwin-rebuild switch --flake .#<host>`.
6. Delete pipenv/ansible-galaxy steps. Update `README.md` and fix the stale
   `bootstrap.sh` reference.

---

## CI validation

Goal: prove changes are **runnable without affecting any local/CI system**. A
full `darwin-rebuild switch` mutates the runner and hits `sudo`/MAS/firewall
steps that fail in CI — so CI **builds the system closure** instead (evaluate +
build every derivation, no activation). nix-darwin's Homebrew/casks/`mas`/
defaults/firewall logic only runs during `switch`, so `build` is safe.

`.github/workflows/validate.yml`:

```yaml
name: validate
on:
  push:          # no branch filter → runs on the `ansible-to-nix` branch and any other
  pull_request:

jobs:
  build:
    runs-on: macos-14        # Apple Silicon → aarch64-darwin, matches /opt/homebrew
    steps:
      - uses: actions/checkout@v4
        # submodules NOT fetched: raw configs use mkOutOfStoreSymlink (path strings,
        # not copied into the store), so the build never reads submodule contents —
        # and this avoids auth failures on the private `dotoverrides` submodule.
        with:
          submodules: false

      - uses: DeterminateSystems/nix-installer-action@main    # enables flakes
      - uses: DeterminateSystems/magic-nix-cache-action@main  # speeds up repeat runs

      - name: flake check
        run: nix flake check

      - name: formatting check
        run: nix fmt -- --check .     # requires flake `formatter` output (nixpkgs-fmt)

      - name: build system closure (no activation)
        run: nix build .#darwinConfigurations.<host>.system --print-build-logs
```

Notes:

- **`build`, never `switch`** — no `sudo`, no cask installs, no MAS login, no
  firewall/defaults changes, no shell change. The runner is unaffected.
- **Feature branch first:** no branch filter, so the workflow validates every
  push on the `ansible-to-nix` branch during the migration and keeps validating
  `master` after cutover — no change needed at merge.
- **Submodules off** is safe: raw configs are out-of-store symlinks (contents
  not read at build time), and the only in-store content the native modules
  pull in (`programs.bat` theme/syntax) is fetched over the network via
  `fetchurl` (fixed-output), not from a submodule.
  ⚠️ If an in-store file is ever moved under a submodule path, fetch that
  (public) submodule.
- **CI host attr** is a fixed `darwinConfigurations.<host>` key we choose,
  independent of the runner's real hostname — deterministic on any machine.
- `nix fmt` needs a `formatter.<system>` output in the flake (default
  `nixpkgs-fmt`; `alejandra` is an alternative). Standalone equivalent:
  `nix run nixpkgs#nixpkgs-fmt -- --check .`.

---

## Removal (end state)

Delete `site.yml`, `requirements.yml`, `Pipfile`, `Pipfile.lock`,
`roles/*/tasks|handlers`, `brew_prefix_fact`. Move `roles/*/files/*` into
`files/`. Keep `bin/`, `dotoverrides`, `Terminal_app/`, docs. Switch Dependabot
from pip to flake inputs (or a `nix flake update` cadence).

---

## Execution phases

Each phase is independently verifiable with `darwin-rebuild build` (and CI).

1. **Skeleton + CI.** `flake.nix` (inputs + `darwinConfigurations.<host>` +
   `formatter` output) that builds and switches as a no-op, plus
   `.github/workflows/validate.yml`.
   *Exit:* flake skeleton builds locally **and** CI goes green on a
   build-closure of the config.
2. **Packages.** CLI formulae → `home.packages`; casks + `mas` → `homebrew.nix`.
   *Exit:* everything installs on a real `switch`.
3. **Dotfiles.**
   1. Raw symlinks: bash, tmux, vim, `githelpers`, `git_template`, `bin`,
      `dotoverrides`.
   2. Native modules: `programs.git`, `programs.ssh`, `programs.bat`,
      `programs.fzf`.
   *Exit:* shell loads; git aliases + delta work; ssh connects; bat theme
   applies; fzf keybindings work.
4. **macOS defaults + activation.** `defaults.nix` + firewall/caps-lock/
   terminal activation scripts.
   *Exit:* settings applied and match the Ansible baseline.
5. **Bootstrap + docs rewrite.**
6. **Remove Ansible.** Final full rebuild on a clean check.

---

## Risks / open items

- Some casks may differ in nixpkgs/brew naming; `appdir=~/Applications` isn't
  supported by nix-darwin's homebrew module (apps land in `/Applications`) —
  confirm acceptable or script it.
- **YouCompleteMe compilation** and the **per-keyboard caps-lock remap** are the
  two genuinely imperative pieces; they survive as activation scripts, not pure
  declarative config.
- home-manager wants to own `~/.ssh/config` and `~/.gitconfig`; the native
  `programs.git`/`programs.ssh` approach embraces that. (`ssh` is the borderline
  native candidate — much of its crypto policy lands in `extraOptions`.)
- `reattach-to-user-namespace` and several completion formulae are likely
  droppable — verify before removing.
