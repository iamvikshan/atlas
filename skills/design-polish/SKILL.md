---
name: design-polish
description: >-
  Final quality pass before shipping. Systematically fixes alignment, spacing,
  consistency, interaction states, and detail issues that separate good UI from
  great UI.
---

<!-- Adapted from pbakaus/impeccable (Apache 2.0) -- see NOTICE.md -->

Perform a meticulous final pass to catch all the small details that separate
good work from great work. The difference between shipped and polished.

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
  2. `.atlas/design.md`.
  3. `teach-design` (required on cold start).
- Stop condition: if the required context is still missing, STOP and run
  `teach-design` first. Do not continue this skill until context is
  confirmed.

## Pre-Polish Assessment

Understand the current state before touching anything:

1. **Review completeness**:
   - Is it functionally complete? (Don't polish incomplete work)
   - Are there known issues to preserve? (Document them clearly for follow-up)
   - What's the quality bar? (MVP vs flagship feature)

2. **Identify polish areas**:
   - Visual inconsistencies
   - Spacing and alignment issues
   - Interaction state gaps
   - Copy inconsistencies
   - Edge cases and error states
   - Loading and transition smoothness

**CRITICAL**: Polish is the last step, not the first.

## Polish Systematically

Work through each dimension methodically:

### Visual Alignment and Spacing

- Everything lines up to grid
- All gaps use the spacing scale (no arbitrary values)
- Optical alignment adjusted for visual weight
- Responsive consistency at all breakpoints
- Grid adherence verified

### Typography Refinement

- Same elements use same sizes/weights throughout
- Line length: 45-75 characters for body text
- Appropriate line heights for font size and context
- No widows or orphans (single words on last line)
- No FOUT/FOIT font loading flashes

### Color and Contrast

- All text meets WCAG AA contrast standards
- No hard-coded colors -- all use design tokens
- Works in all theme variants
- Same colors mean same things throughout
- Focus indicators visible with sufficient contrast
- Tinted neutrals: no pure gray or pure black (0.01 chroma tint)
- No gray text on colored backgrounds

### Interaction States

Every interactive element needs ALL states:

- Default, Hover, Focus, Active, Disabled, Loading, Error, Success

Missing states create confusion and broken experiences.

### Micro-interactions and Transitions

- All state changes animated (150-300ms)
- Consistent easing: ease-out-quart/quint/expo for natural deceleration
- No bounce or elastic easing (dated)
- 60fps animations, only animate transform and opacity
- Respects `prefers-reduced-motion`

### Content and Copy

- Consistent terminology throughout
- Consistent capitalization (Title Case vs Sentence case)
- No typos, grammar errors
- Appropriate length (not too wordy, not too terse)
- Consistent punctuation

### Icons and Images

- All icons from same family or matching style
- Icons sized consistently for context
- Proper optical alignment with adjacent text
- All images have descriptive alt text
- No layout shift from images loading
- Retina support (2x assets for high-DPI)

### Forms and Inputs

- All inputs properly labeled
- Clear, consistent required indicators
- Helpful, consistent error messages
- Logical keyboard tab order
- Consistent validation timing

### Edge Cases and Error States

- All async actions have loading feedback
- Helpful empty states (not blank space)
- Clear error messages with recovery paths
- Confirmation of successful actions
- Handles very long content, missing data, offline gracefully

### Responsiveness

- Test mobile, tablet, desktop
- Touch targets: 44x44px minimum on touch devices
- No text smaller than 14px on mobile
- No horizontal scroll
- Content reflows logically

### Performance

- Optimized critical rendering path
- No layout shift after load (CLS)
- Smooth interactions (no lag or jank)
- Images optimized (format and size)
- Off-screen content lazy-loaded

### Code Quality

- No console.log in production
- No commented-out code
- No unused imports
- Consistent naming conventions
- No TypeScript `any` or ignored errors
- Proper ARIA labels and semantic HTML

## Polish Checklist

- [ ] Visual alignment perfect at all breakpoints
- [ ] Spacing uses design tokens consistently
- [ ] Typography hierarchy consistent
- [ ] All interactive states implemented
- [ ] All transitions smooth (60fps)
- [ ] Copy consistent and polished
- [ ] Icons consistent and properly sized
- [ ] All forms properly labeled and validated
- [ ] Error states helpful
- [ ] Loading states clear
- [ ] Empty states welcoming
- [ ] Touch targets 44x44px minimum
- [ ] Contrast ratios meet WCAG AA
- [ ] Keyboard navigation works
- [ ] Focus indicators visible
- [ ] No console errors or warnings
- [ ] No layout shift on load
- [ ] Respects reduced motion preference
- [ ] Code clean (no TODOs, console.logs, commented code)

## Final Verification

- **Use it yourself**: Actually interact with the feature
- **Test on real devices**: Not just browser DevTools
- **Compare to design**: Match intended design
- **Check all states**: Don't just test the happy path

**NEVER**:

- Polish before it's functionally complete
- Introduce bugs while polishing (test thoroughly)
- Ignore systematic issues (if spacing is off everywhere, fix the system)
- Perfect one thing while leaving others rough (consistent quality level)
