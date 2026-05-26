---
name: design-arrange
description: >-
  Improve layout composition, spatial hierarchy, and visual flow so interfaces
  feel intentional, scannable, and structurally coherent.
---

<!-- Adapted from pbakaus/impeccable (Apache 2.0) -- see NOTICE.md -->

Recompose interface structure through stronger spatial hierarchy, alignment,
and rhythm so content is easier to scan and interactions feel deliberate.

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

## Diagnose Spatial Problems

Identify where arrangement currently fails users:

1. **Hierarchy and flow**:
   - Primary content does not stand out from supporting detail
   - Scanning path is unclear or visually noisy
   - Related items are separated while unrelated items are grouped

2. **Alignment and rhythm**:
   - Misaligned columns, baselines, or action rows
   - Inconsistent spacing scale inside repeated components
   - Abrupt transitions between dense and sparse regions

3. **Responsiveness and resilience**:
   - Layout breaks with long text, empty states, or mobile widths
   - Content reorders unpredictably at breakpoints
   - Interaction targets lose clarity when condensed

## Arrange with Intent

### Establish Structural Priorities

- Define what must be seen first, second, and third
- Group by task relevance, not just by data type
- Use proximity and whitespace to communicate relationships
- Reserve strong contrast and prominent placement for truly primary elements

### Build a Spatial System

- Use a consistent spacing scale; avoid arbitrary pixel values
- Anchor layout to a clear grid or column strategy
- Use deliberate asymmetry only when it strengthens emphasis
- Prevent nested container overload where simpler grouping works better

### Control Reading Flow

- Position headings close to owned content
- Keep action controls near affected content
- Break long vertical runs with meaningful sectional rhythm
- Reduce redundant wrappers that dilute hierarchy

### Responsive Arrangement

- Design mobile-first composition, then enhance for larger screens
- Use container-aware rules when component context changes
- Preserve order of importance when stacking content on small screens
- Keep touch targets and spacing usable under compression

## Edge-Case Stability

Validate arrangement under stress:

- Very long labels, user-generated text, and localization expansion
- Empty, loading, error, and partial-data states
- Extremely dense lists or cards with mixed content heights
- Keyboard navigation order and focus visibility in all layouts

## Arrangement Completion Checklist

- [ ] Primary-to-secondary hierarchy is obvious
- [ ] Spacing and alignment are system-consistent
- [ ] Reading and interaction flow are predictable
- [ ] Mobile and narrow layouts preserve intent
- [ ] Edge cases do not collapse structure or usability

**NEVER**:

- Rearrange solely for visual novelty without user benefit
- Solve hierarchy by adding more decoration or more containers
- Force symmetry when content semantics require asymmetry
- Treat responsive behavior as a post-hoc patch
- Ignore keyboard and focus flow when restructuring layout
