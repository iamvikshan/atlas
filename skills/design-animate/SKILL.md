---
name: design-animate
description: >-
  Review a feature and enhance it with purposeful animations,
  micro-interactions, and motion effects that improve usability and delight.
---

<!-- Adapted from pbakaus/impeccable (Apache 2.0) -- see NOTICE.md -->

Analyze a feature and strategically add animations and micro-interactions that
enhance understanding, provide feedback, and create delight.

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
- Additional context for this skill: performance constraints and motion
  sensitivity expectations.

---

## Assess Animation Opportunities

Analyze where motion would improve the experience:

1. **Identify static areas**:
   - **Missing feedback**: Actions without visual acknowledgment (button
     clicks, form submission, etc.)
   - **Jarring transitions**: Instant state changes that feel abrupt
     (show/hide, page loads, route changes)
   - **Unclear relationships**: Spatial or hierarchical relationships that
     aren't obvious
   - **Lack of delight**: Functional but joyless interactions
   - **Missed guidance**: Opportunities to direct attention or explain
     behavior

2. **Understand the context**:
   - What's the personality? (Playful vs serious, energetic vs calm)
   - What's the performance budget? (Mobile-first? Complex page?)
   - Who's the audience? (Motion-sensitive users? Power users who want speed?)
   - What matters most? (One hero animation vs many micro-interactions?)

If any of these are unclear from the codebase, exhaust local conventions first;
ask only as a last resort.

**CRITICAL**: Respect `prefers-reduced-motion`. Always provide non-animated
alternatives for users who need them.

## Plan Animation Strategy

Create a purposeful animation plan:

- **Hero moment**: What's the ONE signature animation? (Page load? Hero
  section? Key interaction?)
- **Feedback layer**: Which interactions need acknowledgment?
- **Transition layer**: Which state changes need smoothing?
- **Delight layer**: Where can we surprise and delight?

**IMPORTANT**: One well-orchestrated experience beats scattered animations
everywhere. Focus on high-impact moments.

## Implement Animations

Add motion systematically across these categories:

### Entrance Animations

- **Page load choreography**: Stagger element reveals (100-150ms delays),
  fade + slide combinations
- **Hero section**: Dramatic entrance for primary content (scale, parallax, or
  creative effects)
- **Content reveals**: Scroll-triggered animations using intersection observer
- **Modal/drawer entry**: Smooth slide + fade, backdrop fade, focus
  management

### Micro-interactions

- **Button feedback**:
  - Hover: Subtle scale (1.02-1.05), color shift, shadow increase
  - Click: Quick scale down then up (0.95 -> 1), ripple effect
  - Loading: Spinner or pulse state
- **Form interactions**:
  - Input focus: Border color transition, slight scale or glow
  - Validation: Shake on error, check mark on success, smooth color
    transitions
- **Toggle switches**: Smooth slide + color transition (200-300ms)
- **Checkboxes/radio**: Check mark animation, ripple effect
- **Like/favorite**: Scale + rotation, particle effects, color transition

### State Transitions

- **Show/hide**: Fade + slide (not instant), appropriate timing (200-300ms)
- **Expand/collapse**: Height transition with overflow handling, icon rotation
- **Loading states**: Skeleton screen fades, spinner animations, progress bars
- **Success/error**: Color transitions, icon animations, gentle scale pulse
- **Enable/disable**: Opacity transitions, cursor changes

### Navigation & Flow

- **Page transitions**: Crossfade between routes, shared element transitions
- **Tab switching**: Slide indicator, content fade/slide
- **Carousel/slider**: Smooth transforms, snap points, momentum
- **Scroll effects**: Parallax layers, sticky headers with state changes,
  scroll progress indicators

### Feedback & Guidance

- **Hover hints**: Tooltip fade-ins, cursor changes, element highlights
- **Drag & drop**: Lift effect (shadow + scale), drop zone highlights, smooth
  repositioning
- **Copy/paste**: Brief highlight flash on paste, "copied" confirmation
- **Focus flow**: Highlight path through form or workflow

### Delight Moments

- **Empty states**: Subtle floating animations on illustrations
- **Completed actions**: Confetti, check mark flourish, success celebrations
- **Easter eggs**: Hidden interactions for discovery
- **Contextual animation**: Weather effects, time-of-day themes, seasonal
  touches

**Delight anti-slop mapping**:

- Delight must reinforce product value and brand personality, not decorate
  arbitrarily.
- Avoid generic AI delight defaults (unprompted confetti bursts, sparkle
  trails, ambient neon glows, floating decorative blobs) unless context
  explicitly requires them.
- Prefer contextual, user-earned moments tied to meaningful progress.

## Technical Implementation

Use appropriate techniques for each animation:

### Timing & Easing

**Durations by purpose:**

- **100-150ms**: Instant feedback (button press, toggle)
- **200-300ms**: State changes (hover, menu open)
- **300-500ms**: Layout changes (accordion, modal)
- **500-800ms**: Entrance animations (page load)

**Easing curves (use these, not CSS defaults):**

```css
:root {
  --ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);
  --ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);
  --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
}

/* AVOID */
/* bounce: cubic-bezier(0.34, 1.56, 0.64, 1); */
/* elastic: cubic-bezier(0.68, -0.6, 0.32, 1.6); */
```

**Exit animations are faster than entrances.** Use ~75% of enter duration.

### CSS Animations

```css
/* Prefer CSS for simple, declarative motion */
.button {
  transition:
    transform 150ms var(--ease-out-quart),
    opacity 150ms var(--ease-out-quart);
}

.button:hover {
  transform: translateY(-1px);
}

.toast-enter {
  animation: toast-enter 300ms var(--ease-out-expo);
}

@keyframes toast-enter {
  from {
    opacity: 0;
    transform: translateY(8px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

### JavaScript Animation

```javascript
// Use the Web Animations API for interactive or stateful motion.
element.animate(
  [
    { opacity: 0, transform: 'translateY(8px)' },
    { opacity: 1, transform: 'translateY(0)' },
  ],
  {
    duration: 300,
    easing: 'cubic-bezier(0.16, 1, 0.3, 1)',
    fill: 'both',
  }
)

// Framework options:
// - Framer Motion for React component choreography
// - GSAP for complex timelines and sequenced effects
```

### Performance

- **GPU acceleration**: Use `transform` and `opacity`, avoid layout
  properties
- **will-change**: Add sparingly for known expensive animations
- **Reduce paint**: Minimize repaints, use `contain` where appropriate
- **Monitor FPS**: Ensure 60fps on target devices

### Accessibility

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

**NEVER**:

- Use bounce or elastic easing curves -- they feel dated and draw attention to
  the animation itself
- Animate layout properties (width, height, top, left) -- use transform
  instead
- Use durations over 500ms for feedback -- it feels laggy
- Animate without purpose -- every animation needs a reason
- Ignore `prefers-reduced-motion` -- this is an accessibility violation
- Animate everything -- animation fatigue makes interfaces feel exhausting
- Block interaction during animations unless intentional
- Add generic delight gimmicks that feel templated rather than brand-specific

## Verify Quality

Test animations thoroughly:

- **Smooth at 60fps**: No jank on target devices
- **Feels natural**: Easing curves feel organic, not robotic
- **Appropriate timing**: Not too fast (jarring) or too slow (laggy)
- **Reduced motion works**: Animations disabled or simplified appropriately
- **Doesn't block**: Users can interact during/after animations
- **Adds value**: Makes interface clearer or more delightful

Remember: Motion should enhance understanding and provide feedback, not just
add decoration. Animate with purpose, respect performance constraints, and
always consider accessibility. Great animation is invisible -- it just makes
everything feel right.
