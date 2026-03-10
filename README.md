# Bridge OS

![Version](https://img.shields.io/badge/version-0.1.2-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Works with Design OS](https://img.shields.io/badge/works%20with-Design%20OS-purple)
![Works with Agent OS](https://img.shields.io/badge/works%20with-Agent%20OS-orange)

> The missing connection between Design OS and Agent OS.

Bridge OS is the single entry point for AI-first product development. It installs and connects [Design OS](https://github.com/buildermethods/design-os) and [Agent OS](https://github.com/buildermethods/agent-os) — ensuring the design phase always happens before implementation begins.

---

## Why Bridge OS

Design OS produces a complete handoff package — components, tokens, user flows, and prompts. Agent OS consumes standards to align the agent before building. The problem: neither tool knows the other exists, and every new project requires installing and wiring both manually.

Bridge OS fills that gap:

- **One entry point** — a single `curl` installs Bridge OS, which then sets up everything else
- **Single session** — Design OS, Bridge OS, and Agent OS commands all run from one Claude Code session
- **Enforced order** — a phase lock prevents Agent OS from running without a completed Design OS export
- **Automatic translation** — the Design OS export becomes a `design-system.md` standard that Agent OS reads automatically
- **Full design guidance** — `/bridge-design` walks you through the entire design phase, detecting where you left off

---

## How it works

```
curl ... | bash          ← install Bridge OS globally (once)
       ↓
/bridge-init             ← install Design OS + Agent OS + configure project
       ↓
/bridge-design           ← guided design phase (vision → sections → export)
       ↓
/bridge-sync             ← connect export to Agent OS standards
       ↓
/bridge-build            ← inject standards + shape specs per section
       ↓
/shape-spec              ← build with confidence
       ↓
/bridge-evolve           ← add sections, redesign, or update tokens
```

### What happens during sync

```
bridge-design/product-plan/        agent-os/standards/global/
  design-system/                →    design-system.md  (tokens + components + rules)
  sections/                     →
  shell/                        →
  product-overview.md           →  agent-os/product/design-requirements.md
```

---

## Requirements

- Node.js v18+
- Git
- [`yq`](https://github.com/mikefarah/yq) _(optional but recommended)_

> Design OS and Agent OS do not need to be installed manually.
> `/bridge-init` handles everything automatically.

---

## Installation

### 1. Install Bridge OS globally — one command, one time

```bash
curl -sSL https://raw.githubusercontent.com/franciscorodriguezsv24/bridge-os/main/setup/install.sh | bash
```

This sets up `~/.bridge-os/` on your system. You only need to do this once.

### 2. Set up your project

```bash
# Create your project
npx create-next-app@latest my-project --typescript --tailwind --app --src-dir
cd my-project

# Bootstrap Bridge OS commands (required once to make /bridge-init available)
~/.bridge-os/setup/project.sh

# Open Claude Code
claude
```

### 3. Let Bridge OS take it from here

```
/bridge-init
```

This installs Design OS, Agent OS, and wires everything together.
You never need to install or configure either tool manually.

---

## Commands

| Command | Phase | What it does |
|---------|-------|-------------|
| `/bridge-init` | Setup | Installs Design OS + Agent OS + configures the project in one step |
| `/bridge-design` | Design | Guides the full design phase — detects progress and continues from where you left off |
| `/bridge-sync` | Bridge | Connects the Design OS export to Agent OS standards |
| `/bridge-build` | Build | Injects standards and shapes a spec for each roadmap section |
| `/bridge-evolve` | Evolve | Add sections, redesign, or update tokens after initial build |
| `/bridge-status` | Any | Shows current phase and verifies all checks |

All Bridge OS and Agent OS commands are installed automatically into
`.claude/commands/` during project setup.

---

## Usage

### Full flow — new project

```
/bridge-init      ← installs Design OS + Agent OS
/bridge-design    ← vision → sections → export (guided)
/bridge-sync      ← connects export to Agent OS
/bridge-build     ← injects standards + shapes specs per section
/shape-spec       ← start building
```

### Adding sections or updating the design post-build

```
/bridge-evolve    ← add sections, redesign, update tokens, or update data shape
```

This command handles the full cycle: design change → re-export → sync → new spec.

### Re-syncing after a design change

If you updated the design and ran `/export-product` again:

```
/bridge-sync
```

Or from the terminal:

```bash
.bridge-os/sync.sh
```

### Partial syncs

```bash
.bridge-os/sync.sh --tokens-only      # only tokens changed
.bridge-os/sync.sh --section dashboard # one section redesigned
.bridge-os/sync.sh --dry-run           # preview without writing
```

### Updating after a Bridge OS release

```bash
cd ~/.bridge-os && git pull origin main
cd your-project
~/.bridge-os/setup/project.sh --update  # refreshes scripts + all commands
```

---

## Project structure

After setup, your project will look like this:

```
your-project/
├── bridge-design/              ← Design OS repo (git-ignored)
│   └── product-plan/           ← generated by /export-product
│       ├── design-system/      ← tokens.css, tailwind-colors.css, fonts.md
│       ├── sections/           ← section components
│       ├── shell/              ← app shell and navigation
│       ├── prompts/            ← one-shot-prompt.md, section-prompt.md
│       └── product-overview.md
├── agent-os/                   ← Agent OS
│   ├── standards/global/
│   │   └── design-system.md   ← generated by Bridge OS sync
│   └── product/
│       └── design-requirements.md
├── design-export/              ← copy of Design OS export (git-ignored)
├── .bridge-os/                 ← Bridge OS config and scripts
│   ├── config.yml              ← local config (git-ignored)
│   ├── state.json              ← current phase (git-ignored)
│   ├── sync.sh
│   └── generate-standard.js
├── .claude/
│   └── commands/
│       ├── bridge-init.md
│       ├── bridge-design.md
│       ├── bridge-build.md
│       ├── bridge-evolve.md
│       ├── bridge-status.md
│       ├── bridge-sync.md
│       └── design-os/          ← Design OS commands (copied by /bridge-init)
│           ├── product-vision.md
│           ├── product-roadmap.md
│           ├── data-shape.md
│           ├── design-tokens.md
│           ├── design-shell.md
│           ├── shape-section.md
│           └── export-product.md
└── src/                        ← your app code
```

---

## Troubleshooting

### `bash: line 1: 404:: command not found` when installing Agent OS

The Agent OS install script URL changed in v3. Use the correct URL:

```bash
curl -sSL "https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh" | bash
```

Note: Agent OS v3 installs to `~/agent-os/` (no dot), not `~/.agent-os/`.

---

### `permission denied: ~/.bridge-os/setup/project.sh`

Git does not always preserve execute permissions when cloning.
Fix it manually:

```bash
chmod +x ~/.bridge-os/setup/project.sh
chmod +x ~/.bridge-os/setup/install.sh
chmod +x ~/.bridge-os/scripts/sync.sh
```

Then re-run `~/.bridge-os/setup/project.sh`.

To avoid this in the future, re-run the global installer which now
sets permissions automatically:

```bash
curl -sSL https://raw.githubusercontent.com/franciscorodriguezsv24/bridge-os/main/setup/install.sh | bash
```

---

### `🚫 PHASE LOCK: Design OS export not found`

Bridge OS cannot find the Design OS export. Check two things:

1. Verify `export_dir` in `.bridge-os/config.yml` — it should be `product-plan` for current versions of Design OS
2. Make sure you ran `/export-product` in Design OS before syncing

```yaml
design_os:
  path: "./bridge-design"
  export_dir: "product-plan"   # ← not "export"
```

---

### `⚠ Incomplete export. Missing: ...`

The export folder exists but is missing required files.
Re-run `/export-product` in Design OS to regenerate the full package.

---

### `tokens: none` in sync output

Bridge OS could not read the token files. Verify that
`design-export/design-system/tokens.css` exists and is not empty.
If Design OS generated a different file name, check `design-export/design-system/`
and update `generate-standard.js` accordingly.

---

### `/bridge-status` shows old checks after update

The Claude Code command file is cached. Copy the updated version:

```bash
cp ~/.bridge-os/commands/bridge-status.md .claude/commands/bridge-status.md
```

Or use the update flag to refresh all commands at once:

```bash
~/.bridge-os/setup/project.sh --update
```

---

## What Bridge OS does not do

- Does not modify Design OS or Agent OS source code
- Does not generate application code
- Does not replace any Design OS or Agent OS commands — it orchestrates them

It installs, connects, and enforces order between the two tools — nothing more.

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a PR.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## License

MIT — see [LICENSE](LICENSE).

Built to work alongside [Design OS](https://github.com/buildermethods/design-os) and [Agent OS](https://github.com/buildermethods/agent-os) by [Brian Casel](https://buildermethods.com).