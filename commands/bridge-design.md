# Bridge Design

Guide the user through the complete Design OS process in the correct order.
Every step must be completed before moving to the next.
This command runs inside the `bridge-design/` folder context.

## Important

All Design OS commands (`/product-vision`, `/product-roadmap`, etc.) must be
run from inside the `bridge-design/` directory with its own Claude Code session.

Bridge OS cannot run Design OS commands directly — it guides the user to run
them in the correct order and verifies completion before proceeding.

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
"Open a new Claude Code session in the `bridge-design/` folder and run:
```
/product-vision
```
This defines what you're building, your target users, and core features.
Come back here when it's done."

Ask: "Did `/product-vision` complete successfully?" — wait for confirmation.
Then verify `bridge-design/product/overview.md` exists before continuing.

---

#### Step 2 — Product Roadmap
If `bridge-design/product/roadmap.md` does not exist:

Tell the user:
"In the same `bridge-design/` Claude Code session, run:
```
/product-roadmap
```
This breaks your product into sections (e.g. dashboard, settings, profile).
Each section will become a designed area of your app."

Ask: "Did `/product-roadmap` complete successfully?" — wait for confirmation.
Verify `bridge-design/product/roadmap.md` exists before continuing.

---

#### Step 3 — Data Shape
If `bridge-design/product/data-shape/data-shape.md` does not exist:

Tell the user:
"Run in `bridge-design/`:
```
/data-shape
```
This defines the core data entities your app works with."

Ask: "Did `/data-shape` complete?" — wait for confirmation.

---

#### Step 4 — Design Tokens
If `bridge-design/product/design-system/design-tokens.md` does not exist:

Tell the user:
"Run in `bridge-design/`:
```
/design-tokens
```
This sets your colors, typography, and spacing.
You'll see a live preview at http://localhost:3000."

Ask: "Did `/design-tokens` complete?" — wait for confirmation.
Verify the file exists before continuing.

---

#### Step 5 — App Shell
If `bridge-design/src/shell/` is empty or does not exist:

Tell the user:
"Run in `bridge-design/`:
```
/design-shell
```
This designs your app's navigation and layout — the wrapper around all sections."

Ask: "Did `/design-shell` complete?" — wait for confirmation.

---

#### Step 6 — Section Design
If `bridge-design/product/sections/` has no subfolders:

Read `bridge-design/product/roadmap.md` to get the list of sections.
Tell the user:
"Now design each section from your roadmap. Run for each one:
```
/shape-section
```
Sections to design: [list from roadmap.md]
Run `/shape-section` once per section. Come back after each one."

Ask after each: "Which section did you just design? Are there more sections to design?"
Repeat until all sections from the roadmap are done.

---

#### Step 7 — Export
If `bridge-design/product-plan/` does not exist:

Tell the user:
"All sections are designed. Now generate the full handoff package:
```
/export-product
```
This creates `product-plan/` with everything Bridge OS needs to sync."

Ask: "Did `/export-product` complete?" — wait for confirmation.
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
