# Bridge Build

Orchestrate the transition from design to implementation — inject standards
and shape specs for every section in the roadmap, automatically.

This command closes the gap between `/bridge-sync` and actual development.

## When to use

- Immediately after `/bridge-sync` completes successfully
- When `/bridge-status` shows all checks are ✅ but no specs exist yet

## Prerequisites

Before starting, verify:

1. Read `.bridge-os/state.json` — phase must be `"agent"`
2. Run `/bridge-status` — all checks must be ✅

If any check fails:
- Phase is `"design"` → "Run `/bridge-design` first."
- Phase is `"bridge"` or sync checks fail → "Run `/bridge-sync` first."
- Stop.

---

## Steps

### 1. Load Standards

Tell the user:
"First, I'll load the design standards so every spec we build
is aligned with your design system."

Read the following files directly into context:
- `agent-os/standards/global/design-system.md` (design tokens, components, rules)
- `agent-os/standards/index.yml` (to identify any other relevant standards)
- `agent-os/product/design-requirements.md` (product context from Design OS)

If `design-system.md` does not exist:
"Design system standard is missing. Run `/bridge-sync` first."
Stop.

Summarize the key points from the loaded standards for the user:
- Design tokens (colors, spacing, typography)
- Available components
- Key design rules

These standards will be referenced in every spec created in step 4.

---

### 2. Read the Roadmap

Read `agent-os/product/design-requirements.md` to extract the product context.

Then read `bridge-design/product/roadmap.md` (or `design-export/product-overview.md`
if the roadmap is not directly available) to get the list of sections.

Extract every section name from the roadmap. These are the areas of the app
that were designed in Design OS (e.g. dashboard, settings, profile, onboarding).

If no sections can be identified:
"I couldn't find sections in the roadmap. What sections should we build specs for?"
Use AskUserQuestion and wait for the user to provide the list.

---

### 3. Show the Build Plan

Present the full plan to the user:

---

## 🔨 Bridge Build Plan

Standards have been injected. Now I'll shape a spec for each section
from your roadmap.

| # | Section | Status |
|---|---------|--------|
| 1 | [section-name] | ⏳ |
| 2 | [section-name] | ⏳ |
| ... | ... | ⏳ |

Each spec will be created using `/shape-spec` in plan mode.
I'll go through them one at a time.

**Ready to start with [first section]?**

---

Wait for the user to confirm before proceeding.

---

### 4. Shape Specs — One per Section

For each section in the list:

**a)** Tell the user:
"Shaping spec for **[section-name]**. Entering plan mode."

**b)** Enter plan mode.

**c)** Before running `/shape-spec`, re-read `agent-os/standards/global/design-system.md`
into the plan mode context so the standards are available.

Then run `/shape-spec` with the following pre-filled context:
- **What we're building:** The [section-name] section as defined in the
  Design OS roadmap and design export
- **Visuals:** Point to `design-export/sections/[section-name]/` if it exists
- **References:** Point to `design-export/shell/` for layout context
  and `agent-os/standards/global/design-system.md` for tokens/components
- **Product context:** Read from `agent-os/product/design-requirements.md`
- **Prompts:** If `design-export/prompts/` exists, reference
  `design-export/prompts/section-prompt.md` for implementation guidance

Let `/shape-spec` run its full process (clarify → visuals → references →
standards → generate spec folder → structure plan → complete).

**d)** After the spec is saved, exit plan mode.

**e)** Update the progress table:

| # | Section | Status |
|---|---------|--------|
| 1 | [section-name] | ✅ |
| 2 | [section-name] | ⏳ in progress |
| 3 | [section-name] | ⏳ |

**f)** Ask: "Ready to continue with **[next section]**?"
Wait for confirmation before proceeding to the next section.

---

### 5. All Specs Complete

Once every section has a spec, report:

---

## 🔨 Bridge Build Complete

All sections have been shaped into specs.

| # | Section | Spec |
|---|---------|------|
| 1 | [section-name] | `agent-os/specs/[folder-name]/` |
| 2 | [section-name] | `agent-os/specs/[folder-name]/` |
| ... | ... | ... |

**Standards injected:** ✅
**Specs created:** [count] / [total]

You're ready to start building. Pick any spec and execute its plan.

---

### 6. Do not start implementation automatically.

Wait for the user to choose which spec to execute first.
