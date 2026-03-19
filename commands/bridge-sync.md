# Bridge Sync

Connects your design source to Agent OS standards and product context.
Supports both Figma MCP tokens and Design OS export.

## When to use this command

- After completing `/bridge-design` (either path A or B)
- After updating tokens in Figma and wanting to re-sync
- After re-exporting from Design OS
- When `/bridge-status` reports stale or missing checks

## Steps

### 1. Check design source

Read `.bridge-os/state.json` and check `design_source`.

- If `"figma"` → follow **Path A — Figma Sync** below
- If `"design-os"` or null → follow **Path B — Design OS Sync** below

---

## Path A — Figma Sync

### A-1. Confirm `.bridge-os/figma-tokens.json` exists

If it does not exist:
- Tell the user: "Figma tokens not found. Run `/bridge-design` and choose Path A (Figma MCP) first."
- Stop.

Show the user a summary from `figma-tokens.json`:
- File name and key
- How many colors, typography, and spacing tokens were pulled
- When they were last synced

Ask: "Sync these tokens to Agent OS standards now?" — wait for confirmation.

### A-2. Run Figma sync

Execute:
```
.bridge-os/sync.sh --figma
```

This will:
1. Read `.bridge-os/figma-tokens.json`
2. Generate `agent-os/standards/design-system.md` from Figma tokens
3. Sync product overview and roadmap to `agent-os/product/`
4. Update `.bridge-os/state.json` with phase `"agent"`

### A-3. Confirm and continue

After a successful sync, run `/bridge-status` to confirm all checks are ✅.

Tell the user:
"Figma tokens synced to Agent OS standards.
Run `/bridge-build` to inject standards and shape specs for every section in your roadmap."

### A-4. Re-sync flow (token updates in Figma)

If the user updated tokens in Figma and wants to re-sync:
1. Run `/bridge-design` → Step A-2 again to pull the latest variables
2. Run `.bridge-os/sync.sh --figma` to regenerate `design-system.md`
3. Or for tokens only: `.bridge-os/sync.sh --figma --tokens-only`

---

## Path B — Design OS Sync

### B-1. Check current state

Run `/bridge-status` first to understand the current state.

Confirm with the user before proceeding if:
- The export is stale (hash mismatch) — ask: "Design OS has changed
  since the last sync. Sync now and overwrite the current design-export?"
- The phase is already `agent` — ask: "Bridge is already synced.
  Re-sync and overwrite design-export/?"

### B-2. Execute the sync script

```
.bridge-os/sync.sh
```

If the user wants a partial sync, use the appropriate flag:
- Tokens only: `.bridge-os/sync.sh --tokens-only`
- One section: `.bridge-os/sync.sh --section <section-name>`
- Dry run first: `.bridge-os/sync.sh --dry-run`

### B-3. Confirm and continue

After a successful sync, automatically run `/bridge-status` to confirm all checks are ✅.

If all checks pass, tell the user:
"Bridge sync complete. Run `/bridge-build` to inject standards
and shape specs for every section in your roadmap."

---

## On failure

If `sync.sh` exits with an error:

- **Phase lock triggered (Design OS path)** →
  "Design OS export is missing. Complete `/export-product` in Design OS first,
  then run `/bridge-sync` again."

- **Figma tokens missing (Figma path)** →
  "`.bridge-os/figma-tokens.json` not found. Run `/bridge-design` → Path A first
  to pull your Figma tokens."

- **Incomplete export** (missing files) →
  "The Design OS export is incomplete. Re-run `/export-product` in Design OS
  to regenerate the full package."

- **config.yml missing** →
  "Bridge OS is not initialized in this project. Run `/bridge-init` to set everything up."

- **Node.js error** →
  Show the error output and suggest running `.bridge-os/sync.sh --dry-run` to debug.
