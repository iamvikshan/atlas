# Copilot Atlas

A multi-agent orchestration system for VS Code Copilot that enables complex software development workflows through intelligent agent delegation and parallel execution.

> Built upon the foundation of [copilot-orchestra](https://github.com/ShepAlderson/copilot-orchestra) by ShepAlderson, with agent naming conventions inspired by [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode).

> **Note:** Best supported on VS Code Insiders (as of January 2026) for access to the latest agent orchestration features.

## Overview

This repository contains custom agent prompts that work together to handle the complete software development lifecycle: **Planning → Implementation → Review → Commit**. The system uses a conductor-delegate pattern where a main orchestrator (Atlas) coordinates specialized subagents to efficiently tackle complex development tasks.

## Architecture

### Primary Agents

- **Atlas** (`Atlas.agent.md`) - The ORCHESTRATOR
  - **Model:** Claude Sonnet 4.5 (copilot)
  - Orchestrates the full development lifecycle
  - Delegates to specialized subagents for research, implementation, and review
  - Manages context conservation and parallel execution
  - Handles phase tracking and user approval gates

- **Prometheus** (`Prometheus.agent.md`) - The AUTONOMOUS PLANNER
  - **Model:** GPT-5.2 (copilot)
  - Researches requirements and analyzes codebases
  - Writes comprehensive TDD-driven implementation plans
  - Automatically hands off to Atlas for execution
  - Supports parallel research across multiple subsystems

### Specialized Subagents

- **Oracle-subagent** (`Oracle-subagent.agent.md`) - THE RESEARCHER
  - **Model:** GPT-5.2 (copilot)
  - Gathers comprehensive context about tasks
  - Can delegate to Explorer for large-scope research
  - Returns structured findings to parent agents
  - Supports parallel research across independent subsystems

- **Sisyphus-subagent** (`Sisyphus-subagent.agent.md`) - THE IMPLEMENTER
  - **Model:** Claude Sonnet 4.5 (copilot)
  - Executes implementation following strict TDD principles
  - Writes tests first, then minimal code to pass
  - Handles linting and formatting
  - Can be invoked in parallel for disjoint features

- **Explorer-subagent** (`Explorer-subagent.agent.md`) - THE SCOUT
  - **Model:** Gemini 3 Flash (Preview) (copilot)
  - Rapid file/usage discovery across codebases
  - Read-only exploration (no edits/commands)
  - Returns structured results with file lists and analysis
  - MANDATORY parallel search strategy (3-10 simultaneous searches)

- **Code-Review-subagent** (`Code-Review-subagent.agent.md`) - THE REVIEWER
  - **Model:** GPT-5.2 (copilot)
  - Reviews code for correctness, quality, and test coverage
  - Returns structured feedback (APPROVED/NEEDS_REVISION/FAILED)
  - Can be invoked in parallel for independent phases
  - Focus on blocking issues vs nice-to-haves

- **Frontend-Engineer-subagent** (`Frontend-Engineer-subagent.agent.md`) - THE UI/UX SPECIALIST
  - **Model:** Gemini 3 Pro (Preview) (copilot)
  - Implements user interfaces, styling, and responsive layouts
  - Expert in modern frontend frameworks and tooling
  - Follows TDD principles for frontend (component tests first)
  - Focuses on accessibility and responsive design

## Key Features

### 🔄 Parallel Agent Execution
- Launch multiple subagents simultaneously for independent tasks
- Explorer: 3-10 parallel searches in first batch
- Oracle: Parallel research across multiple subsystems
- Sisyphus: Parallel implementation for disjoint features
- Maximum 10 parallel agents per phase

### 💾 Context Conservation
- Intelligent delegation to preserve context window
- Subagents handle heavy lifting (exploration, research, implementation)
- Conductor synthesizes findings without reading everything
- Clear guidelines on when to delegate vs handle directly

### 🧪 Test-Driven Development
- Every phase follows red-green-refactor cycle
- Tests written first, run to fail, then minimal code
- Explicit test → code → test steps in all plans
- No manual testing unless explicitly requested

### 🤝 Proper Agent Handoffs
- VS Code Custom Agent handoff configuration
- Prometheus → Atlas automatic handoff option
- Each agent can declare available delegations
- Clear handoff workflow with user approval gates

### 📋 Structured Planning
- Atlas-compatible plan format
- 3-10 incremental, self-contained phases
- Open questions with options/recommendations
- Risk assessment and mitigation strategies

## Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/copilot-atlas.git
   ```

2. **Copy agent files to VS Code User prompts directory:**
   - **Windows:** `%APPDATA%\Code\User\prompts\` (or `%APPDATA%\Code - Insiders\User\prompts\` if using Insiders)
   - **macOS:** `~/Library/Application Support/Code/User/prompts/` (or `~/Library/Application Support/Code - Insiders/User/prompts/` if using Insiders)
   - **Linux:** `~/.config/Code/User/prompts/` (or `~/.config/Code - Insiders/User/prompts/` if using Insiders)

3. **Reload VS Code** to recognize the new agents

## Usage

### Planning a Feature with Prometheus

```
Plan a comprehensive implementation for adding user authentication to the app
```

Prometheus will:
1. Research the codebase (delegating to Explorer/Oracle as needed)
2. Write a detailed TDD plan with 3-10 phases
3. Offer to invoke Atlas automatically or let you review first

### Executing a Plan with Atlas

```
Implement the plan devised by Promethus
```

OR: Accept the hand-off from Prometheus by clicking 'Start implementation with Atlas'


Atlas will:
1. Review the plan
2. Delegate Phase 1 implementation to Sisyphus
3. Delegate review to Code-Review
4. Present results and wait for commit approval
5. Continue through all phases

### Direct Research with Oracle

```
Let @Oracle research how the database layer is structured
```

Oracle will:
1. Delegate to Explorer for file discovery (if >10 files)
2. Analyze key files and patterns
3. Return structured findings

### Quick Exploration with Explorer

```
Let @Explorer find all files related to authentication
```

Explorer will:
1. Launch 3-10 parallel searches immediately
2. Read necessary files to confirm relationships
3. Return structured results with file list and analysis

## Workflow Example

```
User: Prometheus, plan adding a user dashboard feature

Prometheus:
  ├─ @Explorer (find UI components)
  ├─ @Oracle (research data fetching patterns)
  ├─ @Oracle (research state management)
  └─ Writes plan → Offers to invoke Atlas

User: Yes, invoke Atlas

Prometheus:
  └─ Atlas, implement the plan...

Atlas: Phase 1/4 - Test Infrastructure
  └─ @Sisyphus Implement Phase 1
      ├─ Writes tests (fail)
      ├─ Writes minimal code
      └─ Tests pass ✓

Atlas: Reviewing Phase 1
  └─ @Code-Review Review Phase 1
      └─ Status: APPROVED ✓

Atlas: Phase 1 complete! [commit message provided]
```

## Configuration

### Plan Directory
Agents check for plan directory configuration:
1. Look for `AGENTS.md` file in workspace
2. Find plan directory specification (e.g., `.sisyphus/plans`)
3. Default to `plans/` if not specified

### Tool Requirements
All agents declare their required tools in YAML frontmatter:
- `agent` - For delegating to other agents
- `edit` - File editing capabilities
- `search` - Semantic/grep search
- `runCommands/runTasks` - Terminal execution
- etc.

### Handoff Declarations
Prometheus declares its handoff to Atlas:
```yaml
handoff:
  - label: Start implementation with Atlas
    agent: Atlas
    prompt: Implement the plan
```

## Requirements

- **VS Code Insiders** (recommended for latest agent features and bug fixes)
- **GitHub Copilot** subscription with multi-agent support
- **VS Code Settings:**
  ```json
  {
    "chat.customAgentInSubagent.enabled": true,
    "github.copilot.chat.responsesApiReasoningEffort": "high"
  }
  ```
  - `customAgentInSubagent.enabled`: Allow subagents to use custom agents defined in a '-agents.md' files like the ones above 
  - `responsesApiReasoningEffort`: Set to "high" for enhanced reasoning in planning agents (GPT models)

## Best Practices

1. **Use Prometheus for complex features** - Let it research and plan before implementation
2. **Leverage parallel execution** - Invoke multiple Explorers/Oracles for large tasks
3. **Trust the TDD workflow** - Each phase is self-contained with tests
4. **Review before proceeding** - Check completed phases before moving forward
5. **Commit frequently** - After each approved phase
6. **Delegate appropriately** - Let subagents handle heavy lifting

## Contributing

Contributions are welcome! Please:
1. Test agent changes thoroughly
2. Maintain the orchestration architecture
3. Follow TDD principles in implementation agents
4. Keep plan format compatible with Atlas
5. Document any new agents or workflows

## License

MIT License

Copyright (c) 2026 Copilot Atlas Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Acknowledgments

This project builds upon the excellent work of:
- **[copilot-orchestra](https://github.com/ShepAlderson/copilot-orchestra)** by [ShepAlderson](https://github.com/ShepAlderson) - Foundation and concept for multi-agent orchestration
- **[oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode)** by [code-yeongyu](https://github.com/code-yeongyu) - Inspiration for agent naming conventions and templates

---

**Note:** These agents are designed to work together. While individual agents can be used standalone, the full power comes from Atlas orchestrating the complete workflow with intelligent delegation and parallel execution.
