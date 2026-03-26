---
name: design-audit
description: >-
  Perform comprehensive audit of interface quality across accessibility,
  performance, theming, responsive design, and AI slop detection. Generates a
  detailed report with severity ratings and actionable fix recommendations.
---

<!-- Adapted from pbakaus/impeccable (Apache 2.0) -- see NOTICE.md -->

Run systematic quality checks and generate a comprehensive audit report with
prioritized issues and actionable recommendations. This is a diagnostic tool --
document issues, do not fix them. Use `/design-normalize`, `/design-polish`,
or `/design-harden` to address findings.

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

## Diagnostic Scan

Run comprehensive checks across these dimensions:

1. **Accessibility (A11y)**
   - Contrast ratios < 4.5:1 (or 7:1 for AAA)
   - Interactive elements without proper ARIA roles, labels, or states
   - Missing focus indicators, illogical tab order, keyboard traps
   - Improper heading hierarchy, missing landmarks, divs instead of buttons
   - Missing or poor image alt text
   - Inputs without labels, poor error messaging, missing required indicators

2. **Performance**
   - Layout thrashing (reading/writing layout properties in loops)
   - Expensive animations (animating width/height/top/left instead of transform/opacity)
   - Missing lazy loading, unoptimized assets, missing will-change
   - Unnecessary imports, unused dependencies
   - Unnecessary re-renders, missing memoization

3. **Theming**
   - Hard-coded colors not using design tokens
   - Broken dark mode: missing variants, poor contrast in dark theme
   - Inconsistent token usage, mixing token types
   - Values that don't update on theme change

4. **Responsive Design**
   - Fixed widths that break on mobile
   - Interactive elements < 44x44px touch targets
   - Horizontal scroll / content overflow on narrow viewports
   - Layouts that break when text size increases
   - Missing breakpoints for mobile/tablet variants

5. **Anti-Patterns (CRITICAL)**
   Check against ALL the DON'T guidelines in the `frontend-design` skill.
   Look for AI slop tells: AI color palette, gradient text, glassmorphism,
   hero metrics, card grids, generic fonts (Inter/Geist defaults). Also check
   for gray on color, nested cards, bounce easing, redundant copy.

**CRITICAL**: This is an audit, not a fix. Document issues thoroughly.

## Report Structure

### Anti-Patterns Verdict

**Start here.** Pass/fail: Does this look AI-generated? List specific tells
from the `frontend-design` skill's anti-patterns section. Be brutally honest.

### Executive Summary

- Total issues found (by severity)
- Most critical issues (top 3-5)
- Overall quality score
- Recommended next steps

### Detailed Findings by Severity

For each issue:

- **Location**: Component, file, line
- **Severity**: Critical / High / Medium / Low
- **Category**: Accessibility / Performance / Theming / Responsive
- **Description**: What the issue is
- **Impact**: How it affects users
- **Standard**: Which WCAG or standard it violates (if applicable)
- **Recommendation**: How to fix it
- **Suggested skill**: Which design skill to use (`/design-normalize`, `/design-polish`, `/design-harden`)

#### Critical Issues

Issues that block core functionality or violate WCAG A.

#### High-Severity Issues

Significant usability/accessibility impact, WCAG AA violations.

#### Medium-Severity Issues

Quality issues, WCAG AAA violations, performance concerns.

#### Low-Severity Issues

Minor inconsistencies, optimization opportunities.

### Patterns and Systemic Issues

Identify recurring problems:

- "Hard-coded colors in 15+ components -- use design tokens"
- "Touch targets consistently < 44px throughout mobile"
- "Missing focus indicators on all custom interactive components"

### Positive Findings

Note what works well. Good practices to maintain. Exemplary implementations
to replicate.

### Recommendations by Priority

1. **Immediate**: Critical blockers (fix first)
2. **Short-term**: High-severity issues (this sprint)
3. **Medium-term**: Quality improvements (next sprint)
4. **Long-term**: Optimizations

### Suggested Skills for Fixes

Map issues to available design skills:

- `/design-normalize` -- align with design system (theming issues)
- `/design-polish` -- final quality pass (spacing, alignment, consistency)
- `/design-harden` -- improve resilience (edge cases, i18n, error handling)

**NEVER**:

- Report issues without explaining impact
- Mix severity levels inconsistently
- Skip positive findings
- Provide generic recommendations -- be specific and actionable
- Report false positives without verification
