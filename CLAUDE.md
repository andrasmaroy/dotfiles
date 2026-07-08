# CLAUDE.md

Ground rules for working in this repository.

## What this is

Personal dotfiles and machine provisioning. Currently managed with Ansible
(`site.yml` + `roles/`). **This is a public repository** — keep
everything generic and reusable by others, not tailored to one machine or
person.

## Commits

- **Atomic commits.** Each commit should be small and stand on its own.
- **No conventional-commit prefixes** (`feat:`, `fix:`, etc.). Write a plain
  message that *explains the change* whenever it is non-trivial (the "why", not
  just the "what"). Trivial changes can have a short one-line message.
- Keep the `Co-Authored-By: Claude` trailer on commits Claude makes.
- **Only ever push to feature branches — never push to `master`.**
- If a commit fails validation (see below), fix it with a **fixup commit**
  (`git commit --fixup <sha>`), not by amending or force-rewriting history in
  place.

## Idempotency

- Applying, building, or deploying this repo **must be idempotent** — safe to
  re-run any number of times with the same result.
- **Prefer declarative over imperative.** When something can be expressed as a
  config option rather than a script step, do that; it is what keeps
  idempotency holding.

## Secrets & personal content

- **Nothing sensitive** may live in this repo — no keys, tokens, passwords, or
  credentials. SSH keys are generated at bootstrap, never committed.
- **Avoid personal / machine-specific content** too (committer name/email,
  hostnames, per-machine paths). This belongs in the external, private
  `dotoverrides` submodule and is pulled in via includes (e.g.
  `gitconfig` ends with `[include] path = ~/.dotoverrides/gitconfig`). When
  something is personal, route it to `dotoverrides` — do not hard-code it here.

## Safety: never mutate the local system

- **Claude must never run system-mutating apply commands.** Applying this repo
  changes the machine (login shell, `/etc/shells`, macOS defaults, firewall,
  `sudo` steps).
- Claude may only run **dry-runs / builds** to validate changes, e.g.:
  - Ansible: `ansible-playbook --check --diff ...`
  - Nix: `nix flake check`, `darwin-rebuild build --flake .#<host>`,
    `nix fmt -- --check .`
- Never run `darwin-rebuild switch`, `nix run nix-darwin -- switch`, or
  `ansible-playbook` without `--check`. The user runs those themselves.

## Validation & CI

- GitHub Actions (`.github/workflows/validate.yml`) is the quality gate.
- **After pushing, use the `gh` CLI to check the validation workflow for each
  commit.** These are read-only queries and are fine to run, e.g.:
  - `gh run list --branch <branch> --workflow validate.yml --limit 1 --json headSha,status,conclusion`
  - `gh run view <run-id> --log-failed` to diagnose a failure.
- Key on `headSha` to confirm you are checking the run for the commit you just
  pushed, not a stale one.
- Treat a commit as done only once its validation run is green; if it is not,
  fix it with a fixup commit (see Commits).

## Submodules

- The repo uses many git submodules (vim plugins and `dotoverrides`). Operate
  with `--recurse-submodules`.
- **Never commit an incidental submodule pointer bump** unless updating that
  submodule *is* the change.
- Treat `dotoverrides` as external and private — never vendor its contents here.

## Platform

- **macOS / Apple Silicon is primary** (`/opt/homebrew` paths, `osx_defaults`,
  Homebrew casks, `mas`).
- Keep the inert Linux branches (`tmux-linux.conf`, Linux paths in
  `bash_profile`, `bin/Darwin` vs generic `bin`) working, but do not invest in
  Linux support unless explicitly asked.

## Style

- **Shell scripts:** `set -euo pipefail`, keep them shellcheck-clean (use
  `# shellcheck disable=...` directives where already conventional), and match
  existing `bin/` conventions.
- **Nix:** formatted with `nixpkgs-fmt` (enforced in CI via `nix fmt --check`);
  one concern per module file.
- Match the style of the surrounding file (the repo mixes bash, Ansible YAML,
  and Nix).

## Developing a plan

Use the below process as the baseline when developing future plans.

1. **Map the current system before proposing anything.** Read the actual files
   — structure, what is installed/configured, how it is bootstrapped — and work
   from evidence, not assumptions.
2. **Resolve the shaping decisions with the user first.** Identify the few
   choices that fundamentally determine the design (architecture, scope, how
   the hard cases are handled), present them as explicit options *with a
   recommendation*, and get answers **before** writing the plan. (Reinforces the
   global rule: ask all questions before producing a plan.)
3. **Justify per-item choices from the actual content.** When classifying how
   each piece is handled, inspect each item and give a per-item rationale rather
   than a blanket rule (e.g. native module vs. raw symlink was decided file by
   file).
4. **Prefer non-destructive validation.** Find a way to prove changes are
   runnable without mutating any system (build/dry-run over apply), and wire it
   into CI as the quality gate.
5. **Write the plan down where it lasts.** Capture the goal, the decisions
   *with their rationale and the options considered*, the target layout, and a
   phased execution path with verifiable exit criteria — in `docs/plans/`.
6. **Execute in small, independently verifiable phases**, each green in CI
   before moving to the next, on the plan's branch.
7. **Iterate in reviewable increments.** Refine the plan in small changes the
   user confirms, and keep the document current as reality diverges.

## Plans & migration

- Design/migration plans live in `docs/plans/`. **Keep them current** as work
  proceeds.
- **Work for a plan goes on a branch named after that plan** (matching the plan
  file). E.g. changes for `docs/plans/ansible-to-nix.md` go on the
  `ansible-to-nix` branch. Combined with the push rule above: never land plan
  work directly on `master`.
- During the Ansible → Nix migration, both systems may coexist on a branch;
  don't assume one has fully replaced the other until the plan says so.
