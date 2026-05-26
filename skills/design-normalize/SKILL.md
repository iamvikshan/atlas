---
name: design-normalize
description: >-
  Normalize design to match the project's design system. Analyzes deviations,
  replaces one-off implementations with system equivalents, and ensures
  consistent tokens, components, and patterns throughout.
---

<!-- Adapted from pbakaus/impeccable (Apache 2.0) -- see NOTICE.md -->

Analyze and redesign the feature to perfectly match the project's design system
standards, aesthetics, and established patterns.

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

## Plan

Before making changes, deeply understand the context:

1. **Discover the design system**: Search for design system documentation,
   UI guidelines, component libraries, or style guides. Study until you
   understand:
   - Core design principles and aesthetic direction
   - Target audience and personas
   - Component patterns and conventions
   - Design tokens (colors, typography, spacing)

   **CRITICAL**: If something is not clear, exhaust local conventions and
   codebase patterns first. Ask only as a last resort.

2. **Analyze the current feature**: Assess what works and what doesn't:
   - Where does it deviate from design system patterns?
   - Which inconsistencies are cosmetic vs. functional?
   - Root cause: missing tokens, one-off implementations, or conceptual
     misalignment?

3. **Create a normalization plan**: Define specific changes:
   - Which components can be replaced with design system equivalents?
   - Which styles need design tokens instead of hard-coded values?
   - How can UX patterns match established user flows?

   **IMPORTANT**: Great design is effective design. Prioritize UX consistency
   and usability over visual polish alone.

## Execute

Systematically address all inconsistencies across these dimensions:

- **Typography**: Use design system fonts, sizes, weights, and line heights.
  Replace hard-coded values with typographic tokens or classes.
- **Color and Theme**: Apply design system color tokens. Remove one-off color
  choices that break the palette.
- **Spacing and Layout**: Use spacing tokens (margins, padding, gaps). Align
  with grid systems and layout patterns used elsewhere.
- **Components**: Replace custom implementations with design system components.
  Ensure props and variants match established patterns.
- **Motion and Interaction**: Match animation timing, easing, and interaction
  patterns to other features.
- **Responsive Behavior**: Ensure breakpoints and responsive patterns align
  with design system standards.
- **Accessibility**: Verify contrast ratios, focus states, ARIA labels match
  design system requirements.
- **Progressive Disclosure**: Match information hierarchy and complexity
  management to established patterns.

**NEVER**:

- Create new one-off components when design system equivalents exist
- Hard-code values that should use design tokens
- Introduce new patterns that diverge from the design system
- Compromise accessibility for visual consistency

## Clean Up

After normalization:

- **Consolidate reusable components**: If you created new components that
  should be shared, move them to the design system or shared UI path.
- **Remove orphaned code**: Delete unused implementations, styles, or files
  made obsolete by normalization.
- **Verify quality**: Lint, type-check, and test. Ensure normalization did not
  introduce regressions.
- **Ensure DRYness**: Look for duplication introduced during refactoring and
  consolidate.
