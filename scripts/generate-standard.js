#!/usr/bin/env node
// =============================================================================
// Bridge OS — generate-standard.js
// Reads Design OS export and generates design-system.md for Agent OS.
// Usage: node generate-standard.js --export <path> --output <path>
// =============================================================================

const fs   = require("fs");
const path = require("path");

// ── Args ──────────────────────────────────────────────────────────────────────
const args       = process.argv.slice(2);
const exportPath = args[args.indexOf("--export") + 1];
const outputPath = args[args.indexOf("--output") + 1];

if (!exportPath || !outputPath) {
  console.error("Usage: node generate-standard.js --export <path> --output <path>");
  process.exit(1);
}

if (!fs.existsSync(exportPath)) {
  console.error(`✗ Export path not found: ${exportPath}`);
  process.exit(1);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// Safely read a JSON file — returns null if missing or invalid
function readJSON(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return null;
  }
}

// Safely read a text file — returns empty string if missing
function readFile(filePath) {
  try {
    return fs.readFileSync(filePath, "utf8");
  } catch {
    return "";
  }
}

// List immediate subdirectories of a folder
function listDirs(dirPath) {
  if (!fs.existsSync(dirPath)) return [];
  return fs.readdirSync(dirPath).filter(f =>
    fs.statSync(path.join(dirPath, f)).isDirectory()
  );
}

// ── 1. Read Design Tokens ─────────────────────────────────────────────────────
// Design OS exports tokens as CSS files, not JSON:
//   design-system/tokens.css        — CSS custom properties
//   design-system/tailwind-colors.css — color tokens
//   design-system/fonts.md          — typography info

function parseTokens(tokensDir) {
  if (!fs.existsSync(tokensDir)) return null;

  const tokensCss  = readFile(path.join(tokensDir, "tokens.css"));
  const colorsCss  = readFile(path.join(tokensDir, "tailwind-colors.css"));
  const fontsMd    = readFile(path.join(tokensDir, "fonts.md"));

  return { tokensCss, colorsCss, fontsMd };
}

// Parse CSS custom properties AND Tailwind color classes
// Handles both:
//   --color-primary: #6366F1;          (CSS custom properties)
//   'primary': '#6366F1',              (Tailwind config JS/CSS)
function parseCSSTokens(css) {
  const rows = [];
  if (!css) return rows;

  // CSS custom properties: --token-name: value;
  const cssRegex = /(--[\w-]+)\s*:\s*([^;}{]+);/g;
  let match;
  while ((match = cssRegex.exec(css)) !== null) {
    rows.push({ token: match[1].trim(), value: match[2].trim() });
  }

  // Tailwind color map: 'key': 'value' or "key": "value"
  if (rows.length === 0) {
    const twRegex = /['"]?([\w-]+)['"]?\s*:\s*['"]([^'"]+)['"]/g;
    while ((match = twRegex.exec(css)) !== null) {
      const key = match[1].trim();
      const val = match[2].trim();
      // Skip non-color-looking values and JS keywords
      if (val.startsWith('#') || val.startsWith('rgb') || val.startsWith('hsl')) {
        rows.push({ token: `--color-${key}`, value: val });
      }
    }
  }

  return rows;
}

// ── 2. Read Components from sections/ and shell/ ──────────────────────────────
function parseComponents(exportPath) {
  const components = [];

  // Design OS puts sections in sections/ and shell in shell/
  const sources = [
    { dir: path.join(exportPath, "sections"), type: "section" },
    { dir: path.join(exportPath, "shell"),    type: "shell"   }
  ];

  for (const { dir, type } of sources) {
    const dirs = listDirs(dir);
    for (const name of dirs) {
      const compDir  = path.join(dir, name);
      // Design OS may have spec.md or README.md per section
      const spec     = readFile(path.join(compDir, "spec.md")) ||
                       readFile(path.join(compDir, "README.md"));

      const variantsMatch = spec.match(/##\s*Variants[\s\S]*?\n([\s\S]*?)(?=\n##|$)/i);
      const variants = variantsMatch
        ? variantsMatch[1]
            .split("\n")
            .map(l => l.replace(/^\|?\s*`?([^|`]+)`?\s*\|?.*/, "$1").trim())
            .filter(l => l && !l.startsWith("-") && !l.startsWith("Variant"))
            .slice(0, 6)
        : [];

      const propsMatch = spec.match(/##\s*Props[\s\S]*?\n([\s\S]*?)(?=\n##|$)/i);
      const props = propsMatch
        ? propsMatch[1]
            .split("\n")
            .map(l => l.replace(/^\|?\s*`?([^|`\s]+)`?.*/, "$1").trim())
            .filter(l => l && !l.startsWith("-") && !l.startsWith("Prop") && l.length > 1)
            .slice(0, 8)
        : [];

      components.push({
        name,
        type,
        path: `design-export/${type === "shell" ? "shell" : "sections"}/${name}/`,
        variants,
        props,
        hasSpec: !!spec
      });
    }
  }

  return components;
}

// ── 3. Build design-system.md ─────────────────────────────────────────────────
function buildStandard({ tokens, components, exportPath }) {
  const timestamp = new Date().toISOString().split("T")[0];
  const lines     = [];

  // ── Header
  lines.push(`# Design System Standards`);
  lines.push(`>`);
  lines.push(`> Auto-generated by Bridge OS`);
  lines.push(`> Source: ${exportPath}`);
  lines.push(`> Last sync: ${timestamp}`);
  lines.push(`>`);
  lines.push(`> ⚠️ Do not edit this file manually — run \`.bridge-os/sync.sh\` to update.`);
  lines.push(``);
  lines.push(`---`);
  lines.push(``);

  // ── Agent Rules (most important — read first)
  lines.push(`## Rules for the Agent`);
  lines.push(``);
  lines.push(`1. **Tokens only** — Never hardcode color, spacing, or typography values.`);
  lines.push(`   Always use the CSS variables defined in the tokens table below.`);
  lines.push(`2. **Use exported components** — If a component exists in \`design-export/components/\`,`);
  lines.push(`   import and use it. Do not re-implement it.`);
  lines.push(`3. **Check user flows first** — Before implementing any screen, read`);
  lines.push(`   \`design-export/user-flows.md\` to understand the correct sequence and states.`);
  lines.push(`4. **Shell is the layout** — The app shell from \`design-export/components/Shell/\``);
  lines.push(`   wraps all sections. Do not create custom layout wrappers.`);
  lines.push(`5. **No new components without a spec** — If a component doesn't exist in`);
  lines.push(`   \`design-export/\`, stop and ask before creating it.`);
  lines.push(``);
  lines.push(`---`);
  lines.push(``);

  // ── Design Tokens
  lines.push(`## Design Tokens`);
  lines.push(``);

  const allTokens    = parseCSSTokens(tokens?.tokensCss);
  const colorTokens  = parseCSSTokens(tokens?.colorsCss);

  if (colorTokens.length > 0) {
    lines.push(`### Colors`);
    lines.push(``);
    lines.push(`| Token | Value |`);
    lines.push(`|-------|-------|`);
    for (const row of colorTokens) {
      lines.push(`| \`${row.token}\` | \`${row.value}\` |`);
    }
    lines.push(``);
  }

  if (allTokens.length > 0) {
    lines.push(`### Tokens`);
    lines.push(``);
    lines.push(`| Token | Value |`);
    lines.push(`|-------|-------|`);
    for (const row of allTokens) {
      lines.push(`| \`${row.token}\` | \`${row.value}\` |`);
    }
    lines.push(``);
  }

  if (tokens?.fontsMd) {
    lines.push(`### Typography`);
    lines.push(``);
    lines.push(tokens.fontsMd.trim());
    lines.push(``);
  }

  if (!colorTokens.length && !allTokens.length && !tokens?.fontsMd) {
    lines.push(`_No token files found in \`design-export/design-system/\`._`);
    lines.push(``);
  }

  lines.push(`---`);
  lines.push(``);

  // ── Components
  lines.push(`## Available Components`);
  lines.push(``);
  lines.push(`The following components are exported in \`design-export/components/\`.`);
  lines.push(`**Import them — do not recreate them.**`);
  lines.push(``);

  if (components.length === 0) {
    lines.push(`_No components found in \`design-export/sections/\` or \`design-export/shell/\`._`);
  } else {
    for (const comp of components) {
      lines.push(`### ${comp.name} ${comp.type === "shell" ? "_(shell)_" : ""}`);
      lines.push(``);
      lines.push(`- **Path:** \`${comp.path}\``);
      if (comp.variants.length > 0) {
        lines.push(`- **Variants:** ${comp.variants.map(v => `\`${v}\``).join(" | ")}`);
      }
      if (comp.props.length > 0) {
        lines.push(`- **Key props:** ${comp.props.map(p => `\`${p}\``).join(", ")}`);
      }
      if (comp.hasSpec) {
        lines.push(`- **Spec:** \`${comp.path}spec.md\``);
      }
      lines.push(``);
    }
  }

  lines.push(`---`);
  lines.push(``);

  // ── Reference files
  lines.push(`## Design OS Reference Files`);
  lines.push(``);
  lines.push(`| File | When to use |`);
  lines.push(`|------|-------------|`);
  lines.push(`| \`design-export/prompts/one-shot-prompt.md\` | Full implementation in one session |`);
  lines.push(`| \`design-export/prompts/section-prompt.md\` | Implement section by section |`);
  lines.push(`| \`design-export/shell/\` | App shell and navigation components |`);
  lines.push(`| \`design-export/sections/\` | Section components with test specs |`);
  lines.push(`| \`design-export/product-overview.md\` | Product context and requirements |`);
  lines.push(``);

  return lines.join("\n");
}

// ── Main ──────────────────────────────────────────────────────────────────────
const tokensDir  = path.join(exportPath, "design-system");
const tokens     = parseTokens(tokensDir);
const components = parseComponents(exportPath);
const standard   = buildStandard({ tokens, components, exportPath });

// Write output
const outputDir = path.dirname(outputPath);
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });
fs.writeFileSync(outputPath, standard, "utf8");

const colorCount = parseCSSTokens(tokens?.colorsCss).length;
const tokenCount = parseCSSTokens(tokens?.tokensCss).length;
console.log(`   ✓ design-system.md written (${components.length} components, ${colorCount} colors, ${tokenCount} tokens)`);