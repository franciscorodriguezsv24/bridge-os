# Bridge OS

> The missing connection between Design OS and Agent OS.

Bridge OS is a lightweight protocol that connects the [Design OS](https://github.com/buildermethods/design-os) export with [Agent OS](https://github.com/buildermethods/agent-os) standards — ensuring the design phase is always completed before implementation begins.

It does not replace either tool. It makes them work together.

---

## What it does

Design OS produces a complete handoff package — components, tokens, user flows, and prompts. Agent OS consumes standards to align the agent before building. The problem: neither tool knows the other exists.

Bridge OS fills that gap:

1. Verifies the Design OS export is complete before anything else can happen
2. Translates the export into a `design-system.md` standard that Agent OS reads automatically
3. Enforces the **Design → Bridge → Agent** order through three layers: a phase lock in the sync script, a `/bridge-status` command for Claude Code, and a `CLAUDE.md` section that keeps the agent aligned

---

## How it works

```
Design OS  ──────►  Bridge OS  ──────►  Agent OS
(design)            (connect)           (build)
```

```
/export-product          .bridge-os/sync.sh        /inject-standards
     │                          │                         │
     │  generates               │  copies export          │  loads
     │  export/                 │  generates              │  design-system.md
     ▼                          │  design-system.md       ▼
design-os/export/          ─────┘                  agent-os/standards/
  components/                                        global/
  design-tokens/                                       design-system.md
  user-flows.md
  product-requirements.md
```

---

## Requirements

- [Design OS](https://github.com/buildermethods/design-os) — installed and with at least one `/export-product` completed
- [Agent OS](https://github.com/buildermethods/agent-os) — installed globally and initialized in your project
- Node.js v18+
- Git
- [`yq`](https://github.com/mikefarah/yq) _(optional but recommended for config parsing)_

---

## Installation

### 1. Install Bridge OS globally

```bash
curl -sSL https://raw.githubusercontent.com/franciscorodriguezsv24/bridge-os/main/setup/install.sh | bash
```

This creates `~/.bridge-os/` on your system.

### 2. Install Bridge OS in your project

Navigate to your implementation project (where Agent OS is installed) and run:

```bash
~/.bridge-os/setup/project.sh
```

This will:

- Create `.bridge-os/` with `sync.sh`, `generate-standard.js`, and `config.yml`
- Install `/bridge-status` and `/bridge-sync` commands into `.claude/commands/`
- Append the Bridge OS section to your `CLAUDE.md`
- Update `.gitignore` to exclude runtime files

### 3. Configure paths

Open `.bridge-os/config.yml` and verify the path to your Design OS repo:

```yaml
design_os:
  path: "../my-project-design"  # adjust this to your Design OS repo
  export_dir: "export"

agent_os:
  path: "./"
  standards_dir: "agent-os/standards/global"
  product_dir: "agent-os/product"

bridge:
  export_dest: "design-export"
  enforce_phase_lock: true
```

---

## Usage

### The full flow

**Phase 1 — Design** _(in your Design OS repo)_

```bash
/product-vision
/shape-section    # repeat for each section
/export-product   # generates the handoff package
```

**Phase 2 — Bridge** _(in your implementation project)_

```bash
.bridge-os/sync.sh
```

Bridge OS will verify the export, copy it, generate `design-system.md` for Agent OS, and update the project state to `agent`.

**Phase 3 — Agent** _(in your implementation project)_

```bash
/bridge-status      # verify everything is ready
/inject-standards   # load design context into Agent OS
/shape-spec         # plan your first spec with full design context
```

### Partial syncs

```bash
# Tokens changed only
.bridge-os/sync.sh --tokens-only

# One section was redesigned
.bridge-os/sync.sh --section dashboard

# Preview without writing files
.bridge-os/sync.sh --dry-run
```

### Claude Code commands

| Command | What it does |
|---------|-------------|
| `/bridge-status` | Shows current phase and all checks |
| `/bridge-sync` | Runs the sync from inside Claude Code |

---

## Project structure

After installation, your project will have:

```
your-project/
├── .bridge-os/
│   ├── config.yml            # your local config (git-ignored)
│   ├── state.json            # current phase and sync state (git-ignored)
│   ├── sync.sh               # main sync script
│   └── generate-standard.js  # generates design-system.md
├── .claude/
│   └── commands/
│       ├── bridge-status.md  # /bridge-status command
│       └── bridge-sync.md    # /bridge-sync command
└── design-export/            # copy of Design OS export (git-ignored)
```

---

## What Bridge OS does not do

- Does not modify Design OS or its commands
- Does not modify Agent OS or its existing standards
- Does not generate application code
- Does not replace `/export-product` or `/inject-standards`

It only moves the right output from one tool to the right input of the other.

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a PR.

---

## License

MIT — see [LICENSE](LICENSE).

Built to work alongside [Design OS](https://github.com/buildermethods/design-os) and [Agent OS](https://github.com/buildermethods/agent-os) by [Brian Casel](https://buildermethods.com).