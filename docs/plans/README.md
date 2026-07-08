# Modernization plans

This directory holds design/migration plans for modernization efforts in this
repository. Each plan is a self-contained Markdown document describing the
goal, the decisions taken, the target layout, and a phased execution path with
verifiable exit criteria.

## Conventions

- One file per project, named after the change: `<from>-to-<to>.md` (e.g.
  `ansible-to-nix.md`) or `<topic>.md`.
- **Each plan has a matching feature branch named after the plan file**
  (`ansible-to-nix.md` → the `ansible-to-nix` branch). All work for a plan lands
  on that branch — never directly on `master`.
- Record the **decisions** (with the options considered) up front so the
  rationale survives after the work is done.
- Break execution into **phases**, each independently verifiable.
- Keep plans updated as reality diverges; a plan that lies is worse than none.

## Index

| Plan | Status | Summary |
|------|--------|---------|
| [ansible-to-nix.md](ansible-to-nix.md) | Planned | Replace the Ansible-based setup with a flake-based nix-darwin + home-manager configuration. |
