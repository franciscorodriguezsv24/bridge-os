# Bridge Init

Set up a new project with Design OS (or Figma MCP), Agent OS, and Bridge OS — all in one step.
This is the first command to run in any new project.

## When to use

- Starting a new project from scratch
- Project exists but neither Design OS nor Agent OS are installed yet

## Steps

### 1. Confirm with the user

"This will install Agent OS and Bridge OS in the current project, and set up your design source.
Current directory: `[show pwd]`. Proceed?"

If the user says no — stop.

### 2. Check that the global installations exist

**Bridge OS:**
- Check `~/.bridge-os/` exists
- If not → tell the user to run the global installer first:
  `curl -sSL https://raw.githubusercontent.com/franciscorodriguezsv24/bridge-os/main/setup/install.sh | bash`
  Then stop.

**Agent OS:**
- Check `~/agent-os/` exists (v3 installs here, not `~/.agent-os/`)
- If not → run in terminal:
  `curl -sSL "https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh" | bash`
- Confirm it completed successfully

### 3. Choose design source

Ask the user:

---

**How would you like to define your design tokens?**

**A) Figma MCP** — Pull colors, typography, and spacing directly from a Figma file.
- No local Design OS repo needed
- Requires a Figma account and a file with variables defined
- Bridge OS will help you configure the Figma MCP if needed

**B) Design OS** — Full interactive design workflow with live preview at localhost:3000.
- Defines tokens, shell, and section components locally
- Generates a complete design export for Agent OS

**Which path? (A or B)**

---

Save the choice to `.bridge-os/state.json` as `design_source: "figma"` or `"design-os"`.

Then follow the corresponding install path below.

---

---

## PATH A — Figma MCP

### A-4. Set up Figma MCP

**Step 1 — Get a Figma Personal Access Token**

Tell the user:
1. Go to [figma.com](https://www.figma.com) → profile icon → **Settings**
2. Scroll to **Security** → **Personal access tokens**
3. Click **Generate new token**
   - Name: `Bridge OS`
   - Expiration: as needed
   - Scopes: enable **File content** (Read)
4. Copy the token — it starts with `figd_`

Ask: "Paste your Figma token here:"

**Step 2 — Configure Figma MCP in Claude Code settings**

Check if `~/.claude/settings.json` exists. Read it.

Add under `mcpServers` (create the key if it doesn't exist):

```json
"Figma": {
  "command": "npx",
  "args": ["--yes", "figma-developer/mcp", "--stdio"],
  "env": {
    "FIGMA_ACCESS_TOKEN": "<user-token>"
  }
}
```

Write the updated settings file.

**Step 3 — Restart Claude Code**

Tell the user:
"Figma MCP configured ✅. You need to restart Claude Code now to activate it:
1. Press **Cmd+Q** (Mac) or close the Claude Code window
2. Reopen your project: `claude` in the terminal
3. Run `/bridge-init` again — it will detect the design source is already set and skip to install"

Stop here. Do not continue until the user restarts.

---

*(After restart, bridge-init will detect `design_source: "figma"` in state.json and skip Steps A-4, continuing from A-5)*

### A-5. Install Agent OS in the project

Check if `./agent-os/` already exists.
- If yes → skip
- If no → run:
  `~/agent-os/scripts/project-install.sh`

### A-6. Install Bridge OS in the project

Check if `./.bridge-os/config.yml` already exists.
- If yes → run update mode: `~/.bridge-os/setup/project.sh --update`
- If no → run: `~/.bridge-os/setup/project.sh`

### A-7. Verify (Figma path)

- `./agent-os/` exists with `standards/`
- `./.bridge-os/config.yml` exists
- `./.bridge-os/generate-figma-standard.js` exists
- `./.claude/commands/bridge-design.md` exists
- `./.claude/commands/bridge-sync.md` exists
- `./.bridge-os/state.json` has `design_source: "figma"`

### A-8. Report

---

## 🌉 Bridge Init Complete — Figma MCP Path

| Tool | Status |
|------|--------|
| Design OS | ⏭️ Not needed (using Figma MCP) |
| Agent OS | ✅ Installed at `./agent-os/` |
| Bridge OS | ✅ Configured at `./.bridge-os/` |
| Figma MCP | ✅ Configured in `~/.claude/settings.json` |

**Design source:** Figma MCP
**Current phase:** `DESIGN`

**Next step:**
Run `/bridge-design` — choose Path A, paste your Figma file URL, and Bridge OS
will pull your tokens and guide you through product vision and roadmap.

---

Do not proceed automatically. Wait for the user to run `/bridge-design`.

---

---

## PATH B — Design OS

### B-4. Install Design OS inside the project

Check if `./bridge-design/` already exists.
- If yes → tell the user it already exists and skip cloning
- If no → run:
  ```
  git clone https://github.com/buildermethods/design-os.git bridge-design
  cd bridge-design && git remote remove origin && npm install && cd ..
  ```
- Add `bridge-design/` to `.gitignore` if not already present
- Copy Design OS commands to the project:
  ```
  mkdir -p .claude/commands/design-os
  cp -r ./bridge-design/.claude/commands/design-os/*.md .claude/commands/design-os/
  ```

### B-5. Install Agent OS in the project

Check if `./agent-os/` already exists.
- If yes → skip
- If no → run:
  `~/agent-os/scripts/project-install.sh`

### B-6. Install Bridge OS in the project

Check if `./.bridge-os/config.yml` already exists.
- If yes → run update mode: `~/.bridge-os/setup/project.sh --update`
- If no → run: `~/.bridge-os/setup/project.sh`

The project install script will automatically copy Bridge OS,
Agent OS, and Design OS commands into `.claude/commands/`.

### B-7. Verify (Design OS path)

- `./bridge-design/` exists with `package.json`
- `./agent-os/` exists with `standards/`
- `./.bridge-os/config.yml` exists
- `./.claude/commands/bridge-build.md` exists
- `./.claude/commands/bridge-status.md` exists
- `./.claude/commands/bridge-design.md` exists
- `./.claude/commands/bridge-sync.md` exists
- `./.claude/commands/design-os/product-vision.md` exists
- `./.claude/commands/design-os/export-product.md` exists

### B-8. Report

---

## 🌉 Bridge Init Complete — Design OS Path

| Tool | Status |
|------|--------|
| Design OS | ✅ Installed at `./bridge-design/` |
| Agent OS | ✅ Installed at `./agent-os/` |
| Bridge OS | ✅ Configured at `./.bridge-os/` |
| Figma MCP | ⏭️ Not needed (using Design OS) |

**Design source:** Design OS
**Current phase:** `DESIGN`

**Next step:**
Run `/bridge-design` — Bridge OS will guide you through the full design phase
(vision → roadmap → tokens → shell → sections → export).

---

Do not proceed to design or implementation automatically.
Wait for the user to run `/bridge-design`.
