# Bridge Evolve

Evolve an existing project — add new sections, redesign existing ones,
or update the design system after the initial build is complete.

This is the re-entry point for the design-to-implementation cycle.

## When to use

- After `/bridge-build` and implementation are done, and you need to expand
- When a section needs to be redesigned
- When design tokens or data shape need updating

## Prerequisites

1. Read `.bridge-os/state.json` — phase must be `"agent"`
2. All checks from `/bridge-status` must be ✅ (sync was completed at least once)

If phase is not `"agent"`:
"The initial build cycle isn't complete yet. Finish `/bridge-build` first."
Stop.

---

## Steps

### 1. Detect Intent

Ask the user:

---

What would you like to evolve?

| Option | Description |
|--------|-------------|
| **A** | Add a new section |
| **B** | Redesign an existing section |
| **C** | Update design tokens / design system |
| **D** | Update data shape (new or changed entities) |

---

Wait for the user to choose before proceeding.

---

### 2A. Add a New Section

**a)** Ask the user for the section name and a brief description.

**b)** Tell the user:
"Designing the new **[section-name]** section."

Run `/shape-section` directly for the new section.

**c)** After the section design completes, verify:
`bridge-design/product/sections/[section-name]/` exists.

**d)** Update the roadmap:
Read `bridge-design/product/roadmap.md` and append the new section to it.

**e)** Re-export:
"Re-exporting the design package with the new section."

Run `/export-product` directly.

Verify `bridge-design/product-plan/sections/[section-name]/` exists.

**f)** Sync the new section only:
Run in terminal:
```
.bridge-os/sync.sh --section [section-name]
```

**g)** Shape a spec for the new section:
Read `agent-os/standards/global/design-system.md` into context.

Enter plan mode.

Run `/shape-spec` with pre-filled context:
- **What we're building:** The [section-name] section (new addition)
- **Visuals:** `design-export/sections/[section-name]/`
- **References:** `design-export/shell/` for layout context
- **Product context:** `agent-os/product/design-requirements.md`
- **Prompts:** `design-export/prompts/section-prompt.md` if it exists

After spec is saved, exit plan mode.

**h)** Report:

---

## New Section Added

| Step | Status |
|------|--------|
| Section designed | ✅ |
| Roadmap updated | ✅ |
| Export regenerated | ✅ |
| Synced to Agent OS | ✅ |
| Spec created | ✅ `agent-os/specs/[folder-name]/` |

Ready to build **[section-name]**. Execute the spec plan to start.

---

### 2B. Redesign an Existing Section

**a)** List existing sections from `bridge-design/product/sections/`.
Ask: "Which section do you want to redesign?"

Wait for the user to choose.

**b)** Show the current design by reading
`design-export/sections/[section-name]/` and summarizing key components.

**c)** Tell the user:
"Redesigning **[section-name]**. This will overwrite the current design."

Run `/shape-section` directly for the selected section.

**d)** After the section design completes, re-export:
Run `/export-product` directly.

**e)** Sync the updated section:
Run in terminal:
```
.bridge-os/sync.sh --section [section-name]
```

**f)** Compare old and new:
Read the updated `design-export/sections/[section-name]/` and summarize
what changed compared to the previous design (new components, removed
components, layout changes).

**g)** Check for existing specs:
Look in `agent-os/specs/` for any folder containing `[section-name]` in the name.

If a spec exists:
"An existing spec was found at `agent-os/specs/[old-spec-folder]/`.
I'll create a new spec that accounts for the redesign."

**h)** Shape a new spec:
Enter plan mode. Run `/shape-spec` with:
- **What we're building:** Redesign of [section-name] — [summary of changes]
- **Visuals:** `design-export/sections/[section-name]/`
- **References:** The old spec at `agent-os/specs/[old-spec-folder]/` and
  existing implementation code if any

After spec is saved, exit plan mode.

**i)** Report:

---

## Section Redesigned

| Step | Status |
|------|--------|
| Section redesigned | ✅ |
| Export regenerated | ✅ |
| Synced to Agent OS | ✅ |
| Changes summarized | ✅ |
| New spec created | ✅ `agent-os/specs/[folder-name]/` |

**What changed:**
- [summary of design changes]

Ready to implement the redesign. Execute the new spec plan to start.

---

### 2C. Update Design Tokens

**a)** Tell the user:
"Updating design tokens — colors, typography, and spacing."

Run `/design-tokens` directly.

**b)** After tokens are updated, re-export:
Run `/export-product` directly.

**c)** Sync tokens only:
Run in terminal:
```
.bridge-os/sync.sh --tokens-only
```

**d)** Read the updated `agent-os/standards/global/design-system.md` and
summarize what changed (new colors, changed spacing scale, different fonts, etc.).

**e)** List sections that may need updates:
Read `design-export/sections/` and list all existing sections.
Tell the user:
"These sections may reference the old token values and could need updates:
[list of sections]"

**f)** Report:

---

## Design Tokens Updated

| Step | Status |
|------|--------|
| Tokens redesigned | ✅ |
| Export regenerated | ✅ |
| Synced (tokens only) | ✅ |
| design-system.md updated | ✅ |

**What changed:**
- [summary of token changes]

**Sections to review:** [list]

The agent will automatically use the new tokens for any new code.
Existing code may need manual updates where tokens are referenced.

---

### 2D. Update Data Shape

**a)** Tell the user:
"Updating data shape — core entities and their relationships."

Run `/data-shape` directly.

**b)** After data shape is updated, re-export:
Run `/export-product` directly.

**c)** Full sync (data shape changes can affect everything):
Run in terminal:
```
.bridge-os/sync.sh
```

**d)** Read the updated `bridge-design/product/data-shape/data-shape.md` and
summarize what changed (new entities, changed fields, new relationships).

**e)** List sections that may be affected:
For each section in `design-export/sections/`, check if it references
any of the changed entities. List affected sections.

**f)** Report:

---

## Data Shape Updated

| Step | Status |
|------|--------|
| Data shape updated | ✅ |
| Export regenerated | ✅ |
| Full sync complete | ✅ |

**What changed:**
- [summary of data model changes]

**Sections potentially affected:** [list]

Consider running `/bridge-evolve` again to redesign affected sections,
or update their specs manually.

---

### 3. Do not start implementation automatically.

Wait for the user to choose what to do next.
