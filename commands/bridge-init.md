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

7. Report result:

---

## 🌉 Bridge Init Complete

| Tool | Status |
|------|--------|
| Design OS | ✅ Installed at `./bridge-design/` |
| Agent OS | ✅ Installed at `./agent-os/` |
| Bridge OS | ✅ Configured at `./.bridge-os/` |

**Current phase:** `DESIGN`

**Next step:**
Run `/bridge-design` to start the design process in Design OS.

---

8. Do not proceed to design or implementation automatically.
   Wait for the user to run `/bridge-design`.