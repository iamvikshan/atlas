---
name: design-typeset
description: >-
  Improve typographic hierarchy, rhythm, readability, and expressive tone so
  interfaces communicate clearly and feel intentionally crafted.
---

<!-- Adapted from pbakaus/impeccable (Apache 2.0) -- see NOTICE.md -->

Establish and refine a deliberate typography system that improves readability,
clarifies hierarchy, and expresses brand tone with precision.

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

## Assess Typographic Quality

Audit the current implementation before changing styles:

1. **Hierarchy clarity**:
   - Can users instantly distinguish headline, section title, body, and helper
     text?
   - Are heading jumps logical (H1 -> H2 -> H3 without arbitrary shifts)?
   - Are emphasis patterns consistent (weight, size, color, spacing)?

2. **Readability and rhythm**:
   - Body line length in comfortable range (roughly 45-75 characters)
   - Line-height appropriate to size and density
   - Paragraph spacing supports scanning
   - No accidental widows/orphans in key content blocks

3. **Expressive quality**:
   - Type choices align with product tone and audience
   - Repeated fallback to generic defaults (Inter/system sans) is intentional,
     not accidental
   - Display typography serves meaning, not decoration

## Build a Type System

Define a reusable, token-friendly system rather than one-off values.

### Scale and Tokens

- Define a clear scale for display, heading, body, and micro text
- Prefer fluid sizing with `clamp()` to avoid breakpoint-only jumps
- Keep adjacent steps visually distinct but harmonious
- Encode values in design tokens when available

### Font Pairing and Weights

- Use at most 2-3 families in one surface
- Assign explicit role ownership (display vs body vs mono)
- Normalize weight usage (for example 400/500/600/700) to avoid random values
- Validate fallback stack behavior for unavailable fonts

### Body and Long-Form Content

- Prioritize stable body readability over stylistic experimentation
- Ensure robust wrapping (`overflow-wrap`, `hyphens` where appropriate)
- Preserve legibility across zoom levels and narrow containers
- Treat helper and metadata text as secondary, never unreadable

## Micro-Typesetting

Refine details that significantly affect quality perception:

- Tighten or loosen tracking intentionally for display text only
- Align capitalization strategy across UI copy (Title Case vs sentence case)
- Ensure punctuation and numeral styles are consistent in repeated patterns
- Avoid excessive uppercase blocks without sufficient letter spacing
- Balance vertical rhythm between text blocks and surrounding components

## Responsive and Internationalization

- Test with long translations (30-40% text expansion)
- Test CJK and RTL scripts for clipping, overlap, and line-break issues
- Ensure text containers can grow without breaking layout
- Use logical properties where directional behavior matters
- Maintain readable mobile sizes (no overly compressed body text)

## Accessibility Validation

- Confirm contrast meets WCAG AA for all text roles
- Verify heading structure supports assistive navigation
- Check focus labels and helper text remain readable in all states
- Validate scaling up to 200% without loss of content or function

## Typeset Completion Checklist

- [ ] Hierarchy is immediately understandable
- [ ] Body text is comfortable to read across devices
- [ ] Scale is tokenized and internally consistent
- [ ] Typographic tone aligns with brand direction
- [ ] International text and edge cases do not break the interface
- [ ] Contrast and semantics satisfy accessibility requirements

**NEVER**:

- Tune typography without contextual intent
- Use arbitrary one-off font sizes and line heights across components
- Sacrifice readability for novelty
- Depend on color alone to signal emphasis
- Leave desktop-only typography unadapted for mobile
