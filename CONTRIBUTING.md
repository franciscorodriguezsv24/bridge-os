# Contributing to Bridge OS

Thanks for your interest in contributing!

## Before you start
Open an issue first to discuss what you'd like to change.
This avoids duplicate work and ensures alignment.

## How to contribute
1. Fork the repo
2. Create a branch: `git checkout -b feat/your-feature`
3. Make your changes
4. Open a Pull Request with a clear description

## What we welcome
- Bug fixes
- Improvements to sync.sh or generate-standard.js
- New templates
- Documentation improvements

## What to avoid
- Changes that modify Design OS or Agent OS internals
- Breaking changes to the config.yml schema without discussion

## Code style
- Shell scripts: follow existing patterns in sync.sh
- JS: no dependencies beyond Node.js built-ins (keep it lightweight)
- Markdown: clear headers, no fluff