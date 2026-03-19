# Bridge Init

Set up a new project with Design OS, Agent OS, and Bridge OS — all in one step.
This is the first command to run in any new project.

## When to use

- Starting a new project from scratch
- Project exists but neither Design OS nor Agent OS are installed yet

## Steps

1. Confirm with the user:
   "This will install Design OS, Agent OS, and Bridge OS in the current project.
   Current directory: `[show pwd]`. Proceed?"

   If the user says no — stop.

2. Check that the global installations exist:

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

3. Install Design OS inside the project:

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

4. Install Agent OS in the project:

   Check if `./agent-os/` already exists.
   - If yes → skip
   - If no → run:
     `~/agent-os/scripts/project-install.sh`

5. Install Bridge OS in the project:

   Check if `./.bridge-os/config.yml` already exists.
   - If yes → run update mode: `~/.bridge-os/setup/project.sh --update`
   - If no → run: `~/.bridge-os/setup/project.sh`

   The project install script will automatically copy Bridge OS,
   Agent OS, and Design OS commands into `.claude/commands/`.

6. Verify everything installed correctly:
   - `./bridge-design/` exists with `package.json`
   - `./agent-os/` exists with `standards/`
   - `./.bridge-os/config.yml` exists
   - `./.claude/commands/bridge-build.md` exists
   - `./.claude/commands/bridge-status.md` exists
   - `./.claude/commands/bridge-design.md` exists
   - `./.claude/commands/bridge-sync.md` exists
   - `./.claude/commands/design-os/product-vision.md` exists
   - `./.claude/commands/design-os/export-product.md` exists

7. Ask the user about their design source:

"**How do you plan to define your design tokens?**

**A) Figma MCP** — Pull tokens directly from a Figma file (requires Figma access token)
**B) Design OS** — Define tokens interactively with a local live preview

Which path? (A or B — you can also decide later when running `/bridge-design`)"

If the user chooses **A (Figma MCP)**, run the Figma MCP setup:

---

#### 🔧 Figma MCP Setup (optional — only if Path A chosen)

**Step 1 — Get a Figma Personal Access Token**

Tell the user:
1. Go to [figma.com](https://www.figma.com) → profile icon → **Settings**
2. Scroll to **Security** → **Personal access tokens**
3. Click **Generate new token**
   - Name: `Bridge OS`
   - Scopes: enable **File content** (Read)
4. Copy the token — it starts with `figd_`

Ask: "Paste your Figma token here:"

**Step 2 — Add Figma MCP to Claude Code settings**

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

Tell the user:
"Figma MCP configured ✅. Restart Claude Code now to activate it:
1. Press **Cmd+Q** or close the window
2. Reopen: `claude` in the terminal
3. Run `/bridge-design` to start the design phase"

**If the user chooses B or skips** → continue directly to step 8.

---

8. Report result:

---

## 🌉 Bridge Init Complete

| Tool | Status |
|------|--------|
| Design OS | ✅ Installed at `./bridge-design/` |
| Agent OS | ✅ Installed at `./agent-os/` |
| Bridge OS | ✅ Configured at `./.bridge-os/` |
| Figma MCP | ✅ Configured / ⏭️ Skipped (Path B) |

**Current phase:** `DESIGN`

**Next step:**
Run `/bridge-design` to start the design process.

---

9. Do not proceed to design or implementation automatically.
   Wait for the user to run `/bridge-design`.