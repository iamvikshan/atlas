---
name: design-overdrive
description: >-
  Intensify visual direction and interaction energy with disciplined execution
  so the interface feels bold, memorable, and intentionally high-impact.
---

<!-- Adapted from pbakaus/impeccable (Apache 2.0) -- see NOTICE.md -->

Push an interface past safe defaults into a confident high-impact direction
while preserving usability, accessibility, and compositional discipline.

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

## Determine Overdrive Boundaries

Before amplifying, define what must stay stable:

1. **Immutable constraints**:
   - Core task completion speed
   - Accessibility requirements and keyboard support
   - Performance targets and motion safety (`prefers-reduced-motion`)

2. **Amplification targets**:
   - Hero moments and key conversion surfaces
   - Signature typography and spatial gestures
   - High-value interaction feedback moments

3. **Guardrails**:
   - Avoid visual chaos across every surface
   - Keep at least one calm baseline region for contrast
   - Preserve semantic hierarchy under all stylistic changes

## Drive High-Impact Design

### Visual Contrast and Presence

- Increase contrast where it improves hierarchy and emphasis
- Use stronger scale differences between dominant and supporting elements
- Introduce one or two unmistakable signature motifs, not ten
- Keep neutrals and quiet zones to prevent fatigue

### Typographic Energy

- Escalate display typography intentionally (weight, size, tracking)
- Keep body text stable and readable while display treatment intensifies
- Align emphasis style across repeated moments for coherence

### Spatial Dynamism

- Use purposeful asymmetry and composition tension for focal points
- Break rigid grids selectively to create momentum
- Protect readability with disciplined spacing and alignment anchors

### Motion and Feedback

- Use larger but controlled transforms for key transitions
- Sequence reveals to guide attention, not distract from tasks
- Keep micro-interactions crisp and responsive
- Respect reduced-motion preferences with equivalent non-motion cues

### Interaction Tone

- Intensify affordances for primary actions without making everything primary
- Maintain clear state differentiation (default/hover/focus/active/disabled)
- Ensure touch and keyboard interaction remain predictable and forgiving

## Anti-Slop Overdrive Checks

Avoid common "loud but generic" outcomes:

- Default purple-blue gradient hero with no brand logic
- Decorative glow effects masking weak hierarchy
- Uniformly oversized UI with no clear focal intent
- Heavy styling applied equally to every region

Overdrive should feel authored, not algorithmically exaggerated.

## Verification

- Confirm primary journeys are still faster, not slower
- Validate contrast and accessibility after amplification
- Check performance for animation smoothness and repaint cost
- Test dense data and long-text scenarios to prevent collapse

## Overdrive Completion Checklist

- [ ] Amplification is concentrated on high-value moments
- [ ] Accessibility and readability remain intact
- [ ] Motion remains purposeful and performance-safe
- [ ] Visual energy feels distinctive rather than noisy
- [ ] Core workflows remain clear and efficient

**NEVER**:

- Over-amplify every component equally
- Trade interaction clarity for spectacle
- Ignore reduced-motion and contrast requirements
- Use effects without semantic purpose
- Mistake intensity for quality
