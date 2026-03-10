# Changelog

All notable changes to Bridge OS will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com).

---

## [0.1.4] - 2026-03-10

### Added
- `commands/bridge-evolve.md` — new `/bridge-evolve` command: add sections, redesign, update tokens, or update data shape post-build
- Single-session Design OS support: all Design OS commands now run from the project root
- `bridge-init.md`: copies Design OS commands to `.claude/commands/design-os/` after clone
- `setup/project.sh`: new section to install Design OS commands from `./bridge-design/`
- `setup/project.sh`: installs all 6 commands (added `bridge-evolve`)
- `setup/install.sh`: lists `/bridge-evolve` in available commands
- `template/claude-md-section.md.tpl`: added `/bridge-evolve` guidance for post-build changes

### Changed
- `bridge-design.md`: runs Design OS commands directly instead of requiring a separate session
- `bridge-init.md`: verification step checks for Design OS command files

---

## [0.1.3] - 2026-03-06

### Added
- `commands/bridge-build.md` — new `/bridge-build` command: orchestrates inject-standards + shape-spec per roadmap section
- `setup/project.sh`: installs all 5 commands (added `bridge-build`)
- `setup/install.sh`: lists `/bridge-build` in available commands

### Fixed
- `setup/project.sh`: `export_dir` default changed from `"export"` to `"product-plan"` (matches Design OS output)
- `setup/project.sh`: Agent OS commands path updated from `~/.agent-os/commands` to `~/agent-os/commands/agent-os` (v3 path)
- `setup/project.sh`: Design OS detection now checks `./bridge-design` inside project first
- `setup/project.sh`: template path fixed from `templates/` (plural) to `template/` (singular)
- `setup/project.sh`: `bridge-design/` added to `.gitignore` entries
- `scripts/sync.sh`: `product-requirements.md` replaced with `product-overview.md` (cp, hash, dry-run)
- `scripts/sync.sh`: section sync uses `sections/` instead of `components/`
- `scripts/sync.sh`: `--section` flag parsing rewritten with proper `while/shift` loop
- `commands/bridge-init.md`: Agent OS setup path updated to `~/agent-os/scripts/project-install.sh`
- `commands/bridge-init.md`: verification step checks for `bridge-build.md`
- `commands/bridge-status.md`: "all checks pass" now recommends `/bridge-build`
- `commands/bridge-sync.md`: next step points to `/bridge-build`
- `template/claude-md-section.md.tpl`: all file paths corrected to match real export structure

### Changed
- Full command flow is now: `/bridge-init` → `/bridge-design` → `/bridge-sync` → `/bridge-build` → `/shape-spec`

---

## [0.1.2] - 2026-03-05

### Added
- `commands/bridge-init.md` — new `/bridge-init` command: installs Design OS, Agent OS, and Bridge OS in one step
- `commands/bridge-design.md` — new `/bridge-design` command: guides the full design phase with state awareness, detects current progress and continues from where design left off
- `setup/project.sh`: `--update` flag to refresh scripts and commands without touching `config.yml` or `state.json`
- `setup/project.sh`: installs all 4 commands (`bridge-init`, `bridge-design`, `bridge-status`, `bridge-sync`)
- `setup/install.sh`: shows all available commands after installation

### Changed
- Full command flow is now: `/bridge-init` → `/bridge-design` → `/bridge-sync` → `/inject-standards`

---

## [0.1.1] - 2026-03-05

### Fixed
- `sync.sh`: updated `REQUIRED` files to match real Design OS `product-plan/` structure
- `sync.sh`: use `product-overview.md` instead of `product-requirements.md`
- `generate-standard.js`: read CSS tokens from `design-system/tokens.css` instead of JSON
- `generate-standard.js`: parse `tailwind-colors.css` color map in addition to CSS custom properties
- `generate-standard.js`: read components from `sections/` and `shell/` instead of `components/`
- `bridge-status.md`: updated checks to reflect real Design OS export folder names

---

## [0.1.0] - 2026-03-04

### Added
- Initial release
- `sync.sh` with phase lock enforcement
- `generate-standard.js` — converts Design OS export to Agent OS standard
- `/bridge-status` command for Claude Code
- `/bridge-sync` command for Claude Code
- Global install script (`setup/install.sh`)
- Project install script (`setup/project.sh`)
- `CLAUDE.md` section template with Bridge OS rules
- `state.json` phase tracking
- Support for `--dry-run`, `--tokens-only`, and `--section` flags in `sync.sh`
