# **atlas**

`atlas` is a VS Code agent plugin for multi-agent orchestration across planning, implementation, review, and commit workflows.

> Originally forked from [bigguy345/Github-Copilot-Atlas](https://github.com/bigguy345/Github-Copilot-Atlas) which is built upon the foundation of [copilot-orchestra](https://github.com/ShepAlderson/copilot-orchestra) by ShepAlderson.
> Aligned with [Oh My OpenAgent (OmO)](https://github.com/nicholascpark/oh-my-open-agent) principles.


---

## Table of contents

- [Quick start](#quick-start)
- [First run](#first-run)
- [Architecture overview](#architecture-overview)
- [Agents at a glance](#agents-at-a-glance)
- [Modes](#modes)
- [Hooks](#hooks)
- [Skills](#skills)
- [Bundled MCP servers](#bundled-mcp-servers)
- [File structure](#file-structure)
- [Further reading](#further-reading)

---

## Quick start

Install Atlas as a Copilot plugin.

In VS Code (Insiders), open command palette (Ctrl/Cmd+Shift+P) -> type "Chat: Install Plugin from Source" -> then enter path `iamvikshan/atlas`.

If you prefer the Copilot CLI install path, use:

```bash
copilot plugin install atlas
```

Atlas bundles agents, hooks, skills, and MCP servers in one plugin. The plugin manifest is `plugin.json`, and bundled components live under `/`.

> [!WARNING]
>
> `skills`, `MCPs`, and `agents` load with no issues, but bundled `hooks` currently have known-unidentified issues, likely related to VS Code agent plugins being in preview.
>
> for `hooks` to work, `cmd + shift + p` -> `Preferences: Open User Settings (UI)` -> search `@id:chat.hookFilesLocations` -> `Add Item` -> `~/Library/Application Support/Code - Insiders/agentPlugins/github.com/iamvikshan/atlas/hooks` or the equivalent path on your OS and VS Code.

> [!NOTE]
>
> this will work for all local VS Code instances but for Codespaces, in addition to the above fix, you have to manually copy the contents of `scripts/hooks/` to workspace's `scripts/hooks/`.

-----

## First run

> [!IMPORTANT]
>
> Enable plugin support before trying `@atlas`:
>
> ```json
> {
>   "chat.plugins.enabled": true
> }
> ```

On first use:

  - Start a chat with `@atlas`
  - VS Code will prompt for any MCP credentials required by the bundled servers
  - Atlas will use the plugin-scoped agents, hooks, skills, and MCP config automatically

> [!TIP]
>
> Include `ULW` or `YOLO` in your prompt text if you want Atlas Autopilot behavior.

-----

## Architecture overview

```text
User
  |
  +---> prometheus (planner)
  +---> atlas (conductor)
  |      +---> ekko (backend)
  |      +---> aurora (frontend)
  |      +---> forge (infra)
  |      +---> nova (data/ml)
  |      +---> sentry (reviewer)
  |      +---> oracle (research)
  |      +---> killua (scout)
  |      +---> metis (validator)
  |
```

Atlas and Prometheus are both user-facing. Atlas handles execution. Prometheus handles deep planning when the user opens it manually. In Normal mode, Atlas can stop with a Prometheus handoff packet. In ULW/YOLO mode, Atlas plans locally and continues.

For routing rules, review loops, memory behavior, and MCP details, see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

-----

## Agents at a glance

| Agent          | Primary role    | Use it for                                            |
| -------------- | --------------- | ----------------------------------------------------- |
| **atlas** | Conductor       | Routing work, managing phases, and presenting results |
| **prometheus** | Planner         | Deep planning when Atlas asks the user to open it     |
| **ekko** | Backend worker  | APIs, logic, data pipelines, and server-side changes  |
| **aurora** | Frontend worker | UI, styling, accessibility, and interaction work      |
| **forge** | Infra worker    | CI/CD, cloud, containers, and deployment automation   |
| **nova** | Data Scientist  | Jupyter notebooks, log analysis, ML, visualizations   |
| **sentry** | Reviewer        | Adversarial code review, correctness, and security    |
| **oracle** | Researcher      | Documentation lookup, codebase analysis, conventions  |
| **killua** | Scout           | Fast file discovery and dependency mapping            |
| **metis** | Validator       | Pre-plan analysis and plan validation                 |

-----

## Modes

### Normal mode

Atlas pauses between approved phases so the user can accept, pause, or request revisions. If a task needs deep planning, Atlas prepares context and a copyable prompt for the user to paste into `@prometheus`.

### Autopilot mode

Atlas proceeds phase-by-phase without stopping, auto-committing after review passes. If a task would normally require Prometheus, Atlas plans locally and continues through its own validation flow.

> [!WARNING]
>
> Autopilot is triggered only by explicit chat keywords: `ULW` or `YOLO`.
> VS Code `/yolo`, `/autoApprove`, and editor permission settings do not trigger Atlas Autopilot.

-----

## Hooks

Atlas ships with lifecycle hooks in `hooks/quality.json`.

  - Session lifecycle hooks initialize context, preserve state before compaction, and warn about loose ends at stop time.
  - Prompt and tool guard hooks catch Autopilot triggers, read-before-edit violations, and comment-density regressions.
  - Subagent bootstrap hooks inject role-specific behavior before worker execution begins.

> [!NOTE]
>
> PreToolUse/PostToolUse hooks apply to the active agent's own tool calls. Subagent edits are enforced by agent behavior and review loops, not by identical hook coverage.

-----

## Skills

Atlas groups its bundled skills into a few practical buckets:

  - **Design foundation**: `frontend-design`, `teach-design`
  - **Design command discovery**: `design-help`
  - **Design review and polish**: `design-audit`, `design-polish`, `design-normalize`, `design-harden`, `design-critique`, `design-clarify`
  - **Adaptation and interaction**: `design-adapt`, `design-optimize`, `design-animate`, `design-extract`, `design-onboard`, `design-arrange`
  - **Visual direction**: `design-colorize`, `design-bolder`, `design-quieter`, `design-overdrive`
  - **Typography and craft**: `design-typeset`
  - **Engineering**: `security-review`, `vibe-security`, `terraform-patterns`, `postgres-patterns`, `github-triage`

Atlas design slash commands are: `/frontend-design`, `/teach-design`, `/design-help`, `/design-audit`, `/design-polish`, `/design-normalize`, `/design-harden`, `/design-critique`, `/design-clarify`, `/design-adapt`, `/design-optimize`, `/design-animate`, `/design-extract`, `/design-onboard`, `/design-colorize`, `/design-bolder`, `/design-quieter`, `/design-arrange`, `/design-typeset`, `/design-overdrive`.

For provenance and deeper integration notes, see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

-----

## Bundled MCP servers

Atlas ships with 5 MCP servers configured in `plugins/.mcp.jsonc`.

> [!NOTE]
>
> Servers that require credentials prompt on first use. VS Code stores the entered values securely.

Bundled servers:

  - `context7` for library documentation lookup
  - `sequential-thinking` for structured reasoning
  - `exa` and `tavily` for web search and research
  - `stitch-mcp` for UI scaffolding

### Setup requirements

| Server                  | Setup required             | Where to get it                                         |
| ----------------------- | -------------------------- | ------------------------------------------------------- |
| **context7** | API key (optional)         | [context7.com/dashboard](https://context7.com/dashboard) |
| **sequential-thinking** | None                       | --                                                      |
| **exa** | Exa API key                | [dashboard.exa.ai](https://dashboard.exa.ai)            |
| **tavily** | Tavily API key             | [app.tavily.com](https://app.tavily.com)                |
| **stitch-mcp** | Google Stitch API key      | [stitch.withgoogle.com](https://stitch.withgoogle.com/) |

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for detailed server notes and the sequential-thinking support matrix.

-----

## File structure

```text
plugin.json              -- Plugin manifest
README.md                -- User-facing overview and setup
docs/
  ARCHITECTURE.md        -- Internal mechanics and contributor reference
/
  agents/                -- Agent definitions
  hooks/                 -- Hook configuration
  plugins/
    .mcp.json            -- Bundled MCP server configuration
  skills/                -- Bundled skills
scripts/
  git.sh                 -- Git helpers
  hooks/                 -- Hook scripts
```

-----

## Further reading

  - [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) -- routing, validation, review loops, memory, hooks, MCP details
  - `agents/` -- agent definitions
  - `skills/` -- bundled skills
  - `plugins/.mcp.jsonc` -- bundled MCP configuration

