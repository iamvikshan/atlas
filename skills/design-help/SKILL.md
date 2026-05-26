---
name: design-help
description: >-
  Help users choose the right Atlas design command by mapping needs to the
  installed design skills and command workflow.
---

<!-- Adapted from pbakaus/impeccable (Apache 2.0) -- see NOTICE.md -->

Route design requests to the right command quickly and consistently, using the
installed Atlas design command set as the canonical source of truth.

## MANDATORY PREPARATION

Follow `/frontend-design` and its `Context Gathering Protocol` before any
design work.

- Design work must not proceed without confirmed context.
- Required context includes: target audience, primary use cases, and brand
  personality/tone.
- Context cannot be inferred from codebase structure or implementation details
  alone.
- Gather context in this order:
  1. Current instructions in the active thread.
  2. `DESIGN.md`.
  3. `teach-design` (required on cold start).
- Stop condition: if the required context is still missing, STOP and run
  `teach-design` first. Do not continue this skill until context is
  confirmed.

## Canonical Command Map

Use this map to choose commands based on user intent.

- `/frontend-design`: Foundational design reference and anti-slop baseline for
  all UI work.
- `/design-help`: Use when command selection is unclear or when requests span
  multiple design concerns.
- `/design-audit`: Run a comprehensive quality audit before targeted fixes.
- `/design-polish`: Final detail pass before shipping.
- `/design-normalize`: Align one-off UI with the project design system.
- `/design-harden`: Improve resilience for edge cases, errors, and i18n.
- `/design-critique`: Evaluate design effectiveness and UX quality.
- `/design-clarify`: Improve labels, instructions, microcopy, and UX writing.
- `/design-adapt`: Adapt for screen sizes, devices, and contexts.
- `/design-optimize`: Improve UI performance and runtime efficiency.
- `/design-animate`: Add purposeful motion and micro-interactions.
- `/design-extract`: Extract reusable components, tokens, and patterns.
- `/design-onboard`: Improve onboarding, empty states, and first-use flows.
- `/design-colorize`: Add strategic color when interfaces are too monotone.
- `/design-bolder`: Increase visual impact while preserving usability.
- `/design-quieter`: Reduce visual intensity while preserving clarity.
- `/design-arrange`: Improve composition, spatial hierarchy, and flow.
- `/design-typeset`: Improve typographic hierarchy, readability, and rhythm.
- `/design-overdrive`: Intensify visual direction with disciplined execution.

## Routing Procedure

1. Confirm context via `/frontend-design` protocol requirements.
2. Map the user goal to one primary command from the canonical map.
3. Add supporting commands only when the request clearly spans multiple
   concerns.
4. Prefer workflow order for implementation tasks:
   `/design-audit` -> `/design-normalize` -> `/design-harden` ->
   `/design-polish`.
5. If uncertainty remains, run `/design-help` again and provide a concise
   rationale for the selected command sequence.

## Output Contract

When giving command guidance, always provide:

- Selected command(s) from the canonical map.
- One-line justification for each selected command.
- Execution order if more than one command is needed.
- Any prerequisite context still missing before design work can proceed.

**NEVER**:

- Recommend commands that are not installed.
- Skip context confirmation for design execution tasks.
- Propose broad command stacks without a clear user-need mapping.
- Treat `/frontend-design` as optional for design tasks.
