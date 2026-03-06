# Bridge Sync

Run the Bridge OS sync from inside Claude Code — connects the
Design OS export to Agent OS standards and product context.

## When to use this command

- After running `/export-product` in Design OS
- After updating the design and re-exporting
- When `/bridge-status` reports stale or missing checks

## Steps

1. Run `/bridge-status` first to understand the current state.

2. Confirm with the user before proceeding if:
   - The export is stale (hash mismatch) — ask: "Design OS has changed
     since the last sync. Sync now and overwrite the current design-export?"
   - The phase is already `agent` — ask: "Bridge is already synced.
     Re-sync and overwrite design-export/?"

3. Execute the sync script:
   ```
   .bridge-os/sync.sh
   ```

4. If the user wants a partial sync, use the appropriate flag:
   - Tokens only: `.bridge-os/sync.sh --tokens-only`
   - One section: `.bridge-os/sync.sh --section <section-name>`
   - Dry run first: `.bridge-os/sync.sh --dry-run`

5. After a successful sync, automatically run `/bridge-status`
   to confirm all checks are ✅.

6. If all checks pass, tell the user:
   "Bridge sync complete. Run `/bridge-build` to inject standards
   and shape specs for every section in your roadmap."

## On failure

If `sync.sh` exits with an error:

- **Phase lock triggered** (no export found) →
  "Design OS export is missing. Complete `/export-product` in your
  Design OS repo first, then run `/bridge-sync` again."

- **Incomplete export** (missing files) →
  "The Design OS export is incomplete. Re-run `/export-product` in
  Design OS to regenerate the full package."

- **config.yml missing** →
  "Bridge OS is not initialized in this project.
  Run `/bridge-init` to set everything up."

- **Node.js error in generate-standard.js** →
  Show the error output and suggest running
  `.bridge-os/sync.sh --dry-run` to debug without writing files.