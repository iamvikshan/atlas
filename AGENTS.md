# AGENTS.md

Project conventions for the **atlas** agent plugin.

---

## Overview

This is a VS Code agent plugin containing markdown agent instructions, shell scripts, JSON configs, and design skills. No application code, no compile step, no test suite.

## Plan Directory

`.agents/plans/`

## File Types

| Extension   | Purpose                                              |
| ----------- | ---------------------------------------------------- |
| `.agent.md` | Agent instruction files                              |
| `.sh`       | Hook and utility scripts                             |
| `.ps1`      | Windows hook scripts (exception to `.sh` convention) |
| `.json`     | Plugin manifest, hook configs, MCP configs           |
| `.md`       | Skills, docs, references                             |

## Naming Conventions

- File names: `kebab-case`
- Agent names in prose: `**bold**` (e.g., **atlas**, **ekko**)
- Skill directories: `kebab-case` under `skills/`
- Hook scripts: `kebab-case.sh` under `scripts/hooks/` (Windows exception: `kebab-case.ps1` mirrors each `.sh` hook)

## Quality Gates

- `scripts/check-design-command-sync.sh` -- verifies design command inventory is synchronized across docs, agents, and skills
- `scripts/check-design-protocol.sh` -- verifies design skill protocol/preparation invariants
- **sentry** review is mandatory for all changes

## Conventions

- No emojis in any output -- ASCII symbols only
- Agent instruction files use `---` YAML frontmatter for metadata
- Skills use `SKILL.md` + optional `NOTICE.md` for attribution
- Shell scripts use `set -euo pipefail` with jq-based parsing
