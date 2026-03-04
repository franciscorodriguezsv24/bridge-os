# Bridge Status

Check the current state of Bridge OS and determine if the project
is ready to move into the Agent OS implementation phase.

## Steps

1. Read `.bridge-os/state.json` and `.bridge-os/config.yml`

2. Run the following checks and record ✅ or ❌ for each:

   **Design OS**
   - [ ] `design-export/` folder exists in the project
   - [ ] `design-export/design-tokens/` exists
   - [ ] `design-export/components/` exists and has at least one subfolder
   - [ ] `design-export/product-requirements.md` exists
   - [ ] `design-export/user-flows.md` exists

   **Bridge OS**
   - [ ] `.bridge-os/config.yml` exists and has valid paths
   - [ ] `.bridge-os/state.json` exists
   - [ ] `state.json` phase is `"agent"` (not `"design"` or `"bridge"`)

   **Agent OS**
   - [ ] `agent-os/standards/global/design-system.md` exists
   - [ ] `agent-os/product/design-requirements.md` exists

3. Compare the md5 hash of `design-export/product-requirements.md`
   with the `export_hash` stored in `state.json`. If they differ,
   mark export as stale.

4. Report results using this exact format:

---

## 🌉 Bridge OS Status

**Phase:** `[DESIGN | BRIDGE | AGENT]`
**Last sync:** [value from state.json, or "never"]
**Export:** [up to date ✅ | stale ⚠️ | missing ❌]

### Checks

| Area | Check | Status |
|------|-------|--------|
| Design OS | design-export/ present | ✅ / ❌ |
| Design OS | design-tokens present | ✅ / ❌ |
| Design OS | components present | ✅ / ❌ |
| Design OS | product-requirements.md present | ✅ / ❌ |
| Design OS | user-flows.md present | ✅ / ❌ |
| Bridge OS | config.yml valid | ✅ / ❌ |
| Bridge OS | phase is agent | ✅ / ❌ |
| Agent OS | design-system.md present | ✅ / ❌ |
| Agent OS | design-requirements.md present | ✅ / ❌ |

### Next Step

- If **any Design OS check is ❌** →
  "Run `/export-product` in Design OS, then run `.bridge-os/sync.sh`"

- If **any Bridge OS check is ❌** →
  "Run `.bridge-os/sync.sh` to connect Design OS with Agent OS"

- If **export is stale ⚠️** →
  "Design OS has changed since last sync. Run `.bridge-os/sync.sh` to update."

- If **all checks are ✅** →
  "Ready. Run `/inject-standards` then `/shape-spec` in Agent OS."

---

5. If any check is ❌, do not proceed with implementation tasks.
   Wait for the user to resolve the issue before continuing.