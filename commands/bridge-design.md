# Bridge Design

Start or continue the Design OS process from Bridge OS.
This command guides the user through the full design phase —
from product vision to export — before handing off to Agent OS.

## When to use

- After `/bridge-init` to start the design phase
- To continue a design that was paused mid-process
- To redesign a section and re-export before re-syncing

## Steps

1. Check `.bridge-os/state.json`:
   - If phase is `agent` → warn the user:
     "A sync already exists. Running /bridge-design will start a new design
     cycle. After /export-product you'll need to re-run /bridge-sync.
     Continue?"
     If no → stop.

2. Check if Design OS is installed:
   - If `./bridge-design/` does not exist → tell the user:
     "Design OS is not installed. Run `/bridge-init` first."
     Then stop.

3. Check if Design OS dev server is running:
   - If not running → instruct the user to open a new terminal and run:
     ```
     cd bridge-design
     npm run dev
     ```
   - Tell them: "Open http://localhost:3000 to view Design OS while we work."

4. Check current design progress by reading files in `./bridge-design/product/`:

   **If `product/vision.md` does not exist:**
   → Phase: NOT STARTED
   → Tell user: "Starting from the beginning."
   → Run `/product-vision` instructions inline

   **If `product/vision.md` exists but no sections in `product/sections/`:**
   → Phase: VISION COMPLETE
   → Tell user: "Product vision found. Continuing with section design."
   → Run `/shape-section` instructions inline

   **If sections exist but no `product-plan/` folder:**
   → Phase: SECTIONS COMPLETE
   → Tell user: "Sections designed. Ready to export."
   → Run `/export-product` instructions inline

   **If `product-plan/` already exists:**
   → Phase: EXPORT COMPLETE
   → Tell user: "Design export found. You're ready to sync."
   → Skip to step 6

5. After each Design OS command completes, ask:
   - "Do you want to add another section, or are you ready to export?"
   - If another section → repeat `/shape-section`
   - If ready → run `/export-product`

6. Once `/export-product` is complete, verify:
   - `./bridge-design/product-plan/design-system/` exists
   - `./bridge-design/product-plan/sections/` exists
   - `./bridge-design/product-plan/product-overview.md` exists

7. Update `.bridge-os/state.json` phase to `bridge`:
   ```json
   { "phase": "bridge" }
   ```

8. Report result:

---

## 🎨 Design Phase Complete

**Export location:** `./bridge-design/product-plan/`

| File | Status |
|------|--------|
| `design-system/` | ✅ |
| `sections/` | ✅ |
| `shell/` | ✅ |
| `product-overview.md` | ✅ |

**Current phase:** `BRIDGE`

**Next step:**
Run `/bridge-sync` to connect the design with Agent OS.

---

9. Do not run `/bridge-sync` automatically.
   Wait for the user to explicitly run it.