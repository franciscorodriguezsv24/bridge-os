# Changelog

All notable changes to Bridge OS will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com).

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
# Changelog

All notable changes to Bridge OS will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com).

---

## [0.1.1] - 2026-03-05

### Fixed
- `sync.sh`: updated `REQUIRED` files to match real Design OS `product-plan/` structure
- `sync.sh`: use `product-overview.md` instead of `product-requirements.md`
- `generate-standard.js`: read CSS tokens from `design-system/tokens.css` instead of JSON
- `generate-standard.js`: parse `tailwind-colors.css` color map in addition to CSS custom properties
- `generate-standard.js`: read components from `sections/` and `shell/` instead of `components/`
- `bridge-status.md`: updated checks to reflect real Design OS export folder names
- `project.sh`: added `--update` flag to refresh scripts and commands without touching `config.yml` or `state.json`

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