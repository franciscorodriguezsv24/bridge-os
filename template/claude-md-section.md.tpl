## 🌉 Bridge OS

This project uses Bridge OS to connect Design OS with Agent OS.
Design is the source of truth. The agent builds what the design defines.

### Before any UI or implementation task

1. Run `/bridge-status` to check the current phase
2. If phase is not `AGENT` — stop and follow the next step instructions
3. If phase is `AGENT` and all checks are ✅ — proceed normally

### Sources of truth

| I need to know... | Where to look |
|-------------------|---------------|
| Colors / spacing / typography | `agent-os/standards/global/design-system.md` |
| Section designs and components | `design-export/sections/` |
| App shell and navigation | `design-export/shell/` |
| Product requirements | `agent-os/product/design-requirements.md` |
| Product overview | `design-export/product-overview.md` |
| Implementation prompts | `design-export/prompts/` |

### What the agent must never do

- ❌ Hardcode color, spacing, or typography values
- ❌ Recreate a component that already exists in `design-export/sections/`
- ❌ Ignore `design-export/shell/` when implementing navigation
- ❌ Start implementation if `/bridge-status` has any ❌ checks
- ❌ Create a new component without a spec from Design OS