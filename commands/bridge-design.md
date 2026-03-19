# Bridge Design

Guide the user through the complete design phase. Bridge OS supports two paths
for sourcing design tokens — choose one before starting.

---

## Step 0 — Choose your design source

Ask the user:

---

**How would you like to define your design tokens?**

**A) Figma MCP** — Pull colors, typography, and spacing directly from your Figma
file using the Figma MCP integration in Claude Code.
- Requires Figma MCP configured in Claude Code settings
- Tokens sync automatically from Figma variables
- You still define product vision, roadmap, and data shape here

**B) Design OS** — Use the local Design OS repo to define your design system
interactively, with a live preview at localhost:3000.
- Full visual workflow with token editor
- Generates a complete design export (tokens + shell + sections)

**Which path? (A or B)**

---

Save the choice to `.bridge-os/state.json`:
- Path A → `"design_source": "figma"`
- Path B → `"design_source": "design-os"`

Then follow the corresponding path below.

---

---

# PATH A — Figma MCP

## Important

Figma MCP must be configured in Claude Code. The user should have added
`figma-developer/mcp` (or equivalent) to their Claude Code MCP settings.

This path pulls design tokens (colors, typography, spacing) from Figma variables.
Product vision, roadmap, and data shape are still defined through conversation here.

---

## Steps

### A-1. Verify Figma MCP is available

Try calling a Figma MCP tool (e.g. `get_local_variables` with a dummy key or any
lightweight tool) to detect if the Figma MCP is connected.

**If Figma MCP responds correctly → continue to Step A-2.**

**If Figma MCP is NOT available → run the setup guide below before continuing.**

---

#### 🔧 Figma MCP Setup Guide

Tell the user:

"Figma MCP is not connected. Let's set it up — it takes about 2 minutes.
You'll need a Figma account with access to your design file."

**Step 1 — Get a Figma Personal Access Token**

Tell the user:
1. Go to [figma.com](https://www.figma.com) and log in
2. Click your profile icon (top-left) → **Settings**
3. Scroll to **Security** → **Personal access tokens**
4. Click **Generate new token**
   - Name: `Bridge OS` (or anything)
   - Expiration: choose as needed
   - Scopes: enable **File content** (Read)
5. Copy the token — it starts with `figd_`

Ask: "Do you have your Figma token ready? (paste it here or type 'yes' when done)"

**Step 2 — Add Figma MCP to Claude Code settings**

Tell the user:
"Now I'll add the Figma MCP server to your Claude Code settings."

Check if `~/.claude/settings.json` exists. Read it.

Add the following inside the `mcpServers` object (create it if it doesn't exist):

```json
"Figma": {
  "command": "npx",
  "args": ["--yes", "figma-developer/mcp", "--stdio"],
  "env": {
    "FIGMA_ACCESS_TOKEN": "<TOKEN_FROM_STEP_1>"
  }
}
```

Replace `<TOKEN_FROM_STEP_1>` with the actual token the user provided.

The full `~/.claude/settings.json` structure should look like:
```json
{
  "mcpServers": {
    "Figma": {
      "command": "npx",
      "args": ["--yes", "figma-developer/mcp", "--stdio"],
      "env": {
        "FIGMA_ACCESS_TOKEN": "figd_xxxxxxxxxxxx"
      }
    }
  }
}
```

Write the updated settings file.

**Step 3 — Restart Claude Code MCP connection**

Tell the user:
"Settings saved. Now restart Claude Code to activate the Figma MCP:
1. Press **Cmd+Q** (Mac) or close the Claude Code window
2. Reopen your project: `claude` in the terminal
3. Run `/bridge-design` again — Figma MCP will be available"

Stop here. Do not continue until the user restarts and re-runs `/bridge-design`.

---

Once Figma MCP is verified as available, ask the user for their Figma file URL.

A Figma URL looks like:
`https://www.figma.com/file/XXXXXXXXXXX/My-Product`
The file key is the segment after `/file/` → `XXXXXXXXXXX`

### A-2. Pull design tokens from Figma

Use the Figma MCP to read the file's local variables.
Call the available Figma MCP tool (e.g. `get_local_variables` or `figma_get_file_variables`)
with the extracted file key.

Parse the response to extract:
- **Colors** — variables of type COLOR → convert RGBA floats to hex
- **Typography** — variables of type STRING containing font names or sizes
- **Spacing** — variables of type FLOAT in collections named "Spacing", "Scale", or similar
- **Any other relevant variables**

Save the processed tokens to `.bridge-os/figma-tokens.json` in this format:

```json
{
  "source": "figma",
  "fileKey": "<extracted-key>",
  "fileName": "<file name from API>",
  "syncedAt": "<ISO timestamp>",
  "colors": [
    { "name": "Primary/Blue", "cssVar": "--color-primary-blue", "value": "#6366F1" }
  ],
  "typography": [
    { "name": "Font/Sans", "cssVar": "--font-sans", "value": "Inter" },
    { "name": "Font/Size/Base", "cssVar": "--font-size-base", "value": "16px" }
  ],
  "spacing": [
    { "name": "Space/4", "cssVar": "--space-4", "value": "4px" }
  ],
  "other": []
}
```

Rules for naming CSS variables from Figma variable names:
- Replace `/` with `-`
- Lowercase everything
- Prefix by type: colors → `--color-`, fonts → `--font-`, spacing → `--space-`
- Example: `Primary/Blue` → `--color-primary-blue`

Confirm to the user:
"✅ Figma tokens pulled: X colors, Y typography, Z spacing variables."

Show a summary table of the tokens found.

If the Figma MCP is not available or errors out, tell the user:
"Figma MCP is not responding. Ensure `figma-developer/mcp` is configured in your
Claude Code settings, or switch to Path B (Design OS)."

### A-3. Product Vision

Tell the user: "Now let's define what you're building. I'll ask you a few questions."

Ask and document:
1. What is the product name and one-sentence description?
2. Who are the target users?
3. What are the 3-5 core features?
4. What problem does it solve?

Write the answers to `agent-os/product/overview.md`:

```markdown
# Product Overview

## Product
[name and description]

## Target Users
[description]

## Core Features
[list]

## Problem Statement
[problem being solved]
```

### A-4. Product Roadmap

Tell the user: "Now let's define the sections (screens/areas) of your product."

Ask:
- What are the main sections of the app? (e.g. Dashboard, Settings, Profile, Auth)
- What is the priority order for building them?

Write the roadmap to `agent-os/product/roadmap.md`:

```markdown
# Product Roadmap

## Sections

| Priority | Section | Description |
|----------|---------|-------------|
| 1 | [name] | [description] |
...
```

### A-5. Data Shape

Tell the user: "Now let's define the core data entities your app works with."

Ask:
- What are the main data models? (e.g. User, Post, Order)
- What are the key fields for each?

Write to `agent-os/product/data-shape.md`.

### A-6. Finalize Figma design source

Update `.bridge-os/state.json`:
```json
{
  "phase": "bridge",
  "design_source": "figma"
}
```

Report:

---

## 🎨 Figma Design Source — Ready

| Step | Status |
|------|--------|
| Figma tokens pulled | ✅ |
| Product Vision | ✅ |
| Product Roadmap | ✅ |
| Data Shape | ✅ |

**Tokens saved at:** `.bridge-os/figma-tokens.json`

**Next step:**
Run `/bridge-sync` — it will generate your `design-system.md` from Figma tokens
and inject them into Agent OS standards.

---

Do not run `/bridge-sync` automatically. Wait for the user.

---

---

# PATH B — Design OS

## Important

All Design OS commands (`/product-vision`, `/product-roadmap`, etc.) are
installed in `.claude/commands/design-os/` and can be run directly from
the project root. Bridge OS orchestrates them in the correct order.

Design OS commands read from and write to the `bridge-design/` directory.

---

## Steps

### B-1. Verify Design OS is installed

Check that `./bridge-design/` exists and has `package.json`.
- If not → tell the user: "Design OS is not installed. Run `/bridge-init` first."
- Stop.

### B-2. Check dev server

Tell the user:
"Open a new terminal tab and run:
```
cd bridge-design
npm run dev
```
Then open http://localhost:3000 to follow along visually."

Ask: "Is the dev server running?" — wait for confirmation before continuing.

### B-3. Detect current progress

Read the following files to determine which steps are done:

| File | Step it confirms |
|------|-----------------|
| `bridge-design/product/overview.md` | /product-vision ✅ |
| `bridge-design/product/roadmap.md` | /product-roadmap ✅ |
| `bridge-design/product/data-shape/data-shape.md` | /data-shape ✅ |
| `bridge-design/product/design-system/design-tokens.md` | /design-tokens ✅ |
| `bridge-design/src/shell/` (has files) | /design-shell ✅ |
| `bridge-design/product/sections/` (has subfolders) | /shape-section ✅ |
| `bridge-design/product-plan/` (exists) | /export-product ✅ |

Show the user a progress table:

---

## 🎨 Design OS Progress

| Step | Command | Status |
|------|---------|--------|
| Product Vision | `/product-vision` | ✅ / ⏳ |
| Product Roadmap | `/product-roadmap` | ✅ / ⏳ |
| Data Shape | `/data-shape` | ✅ / ⏳ |
| Design Tokens | `/design-tokens` | ✅ / ⏳ |
| App Shell | `/design-shell` | ✅ / ⏳ |
| Section Design | `/shape-section` | ✅ / ⏳ |
| Export | `/export-product` | ✅ / ⏳ |

---

### B-4. Execute missing steps in order

For each step that is ⏳, guide the user to run it.
**Do not skip any step. Do not proceed to the next until the current one is complete.**

---

#### Step 1 — Product Vision
If `bridge-design/product/overview.md` does not exist:

Tell the user:
"Starting with product vision — this defines what you're building,
your target users, and core features."

Run `/product-vision` directly.

After it completes, verify `bridge-design/product/overview.md` exists before continuing.

---

#### Step 2 — Product Roadmap
If `bridge-design/product/roadmap.md` does not exist:

Tell the user:
"Now we'll break your product into sections (e.g. dashboard, settings, profile).
Each section will become a designed area of your app."

Run `/product-roadmap` directly.

Verify `bridge-design/product/roadmap.md` exists before continuing.

---

#### Step 3 — Data Shape
If `bridge-design/product/data-shape/data-shape.md` does not exist:

Tell the user:
"Now we'll define the core data entities your app works with."

Run `/data-shape` directly.

Verify `bridge-design/product/data-shape/data-shape.md` exists before continuing.

---

#### Step 4 — Design Tokens
If `bridge-design/product/design-system/design-tokens.md` does not exist:

Tell the user:
"Now we'll set your colors, typography, and spacing.
You'll see a live preview at http://localhost:3000."

Run `/design-tokens` directly.

Verify `bridge-design/product/design-system/design-tokens.md` exists before continuing.

---

#### Step 5 — App Shell
If `bridge-design/src/shell/` is empty or does not exist:

Tell the user:
"Now we'll design your app's navigation and layout — the wrapper around all sections."

Run `/design-shell` directly.

Verify `bridge-design/src/shell/` has files before continuing.

---

#### Step 6 — Section Design
If `bridge-design/product/sections/` has no subfolders:

Read `bridge-design/product/roadmap.md` to get the list of sections.
Tell the user:
"Now we'll design each section from your roadmap.
Sections to design: [list from roadmap.md]
I'll run `/shape-section` for each one."

Run `/shape-section` for the first section.

After each section completes, ask: "Ready for the next section ([name])?"
Wait for confirmation, then run `/shape-section` for the next one.
Repeat until all sections from the roadmap are done.

---

#### Step 7 — Export
If `bridge-design/product-plan/` does not exist:

Tell the user:
"All sections are designed. Now we'll generate the full handoff package."

Run `/export-product` directly.

Verify `bridge-design/product-plan/design-system/` and
`bridge-design/product-plan/sections/` exist before continuing.

---

### B-5. All steps complete

Once all 7 steps are ✅, update `.bridge-os/state.json`:
```json
{
  "phase": "bridge",
  "design_source": "design-os"
}
```

Report:

---

## 🎨 Design Phase Complete

All Design OS steps completed successfully.

| Step | Status |
|------|--------|
| Product Vision | ✅ |
| Product Roadmap | ✅ |
| Data Shape | ✅ |
| Design Tokens | ✅ |
| App Shell | ✅ |
| Section Design | ✅ |
| Export | ✅ |

**Export location:** `./bridge-design/product-plan/`

**Next step:**
Run `/bridge-sync` to connect the design with Agent OS.

---

### B-6. Do not run `/bridge-sync` automatically.

Wait for the user to explicitly run it.
