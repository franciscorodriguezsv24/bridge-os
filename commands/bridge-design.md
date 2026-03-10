# Bridge Design

Guide the user through the complete Design OS process in the correct order.
Every step must be completed before moving to the next.

## Important

All Design OS commands (`/product-vision`, `/product-roadmap`, etc.) are
installed in `.claude/commands/design-os/` and can be run directly from
the project root. Bridge OS orchestrates them in the correct order.

Design OS commands read from and write to the `bridge-design/` directory.

---

## Steps

### 1. Verify Design OS is installed

Check that `./bridge-design/` exists and has `package.json`.
- If not → tell the user: "Design OS is not installed. Run `/bridge-init` first."
- Stop.

### 2. Check dev server

Tell the user:
"Open a new terminal tab and run:
```
cd bridge-design
npm run dev
```
Then open http://localhost:3000 to follow along visually."

Ask: "Is the dev server running?" — wait for confirmation before continuing.

### 3. Detect current progress

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

### 4. Execute missing steps in order

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

### 5. All steps complete

Once all 7 steps are ✅, update `.bridge-os/state.json`:
```json
{ "phase": "bridge" }
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

### 6. Do not run `/bridge-sync` automatically.

Wait for the user to explicitly run it.
