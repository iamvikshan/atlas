---
name: design-harden
description: >-
  Improve interface resilience through better error handling, i18n support,
  text overflow handling, and edge case management. Makes interfaces robust
  and production-ready against real-world usage.
---

<!-- Adapted from pbakaus/impeccable (Apache 2.0) -- see NOTICE.md -->

Strengthen interfaces against edge cases, errors, internationalization issues,
and real-world usage scenarios that break idealized designs.

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

## Assess Hardening Needs

Identify weaknesses and edge cases:

1. **Test with extreme inputs**:
   - Very long text (names, descriptions, titles)
   - Very short text (empty, single character)
   - Special characters (emoji, RTL text, accents)
   - Large numbers (millions, billions)
   - Many items (1000+ list items, 50+ options)
   - No data (empty states)

2. **Test error scenarios**:
   - Network failures (offline, slow, timeout)
   - API errors (400, 401, 403, 404, 500)
   - Validation errors, permission errors, rate limiting
   - Concurrent operations

3. **Test internationalization**:
   - Long translations (German is often 30% longer than English)
   - RTL languages (Arabic, Hebrew)
   - CJK character sets (Chinese, Japanese, Korean, emoji)
   - Date/time formats, number formats, currency symbols

**CRITICAL**: Designs that only work with perfect data are not production-ready.

## Hardening Dimensions

### Text Overflow and Wrapping

- Single-line truncation with ellipsis where appropriate
- Multi-line clamping for descriptions
- Word-wrap/overflow-wrap for user-generated content
- Flex/grid items with `min-width: 0` to prevent overflow
- Responsive text sizing with `clamp()` for fluid typography
- Test text scaling (zoom to 200%)

### Internationalization (i18n)

- Add 30-40% space budget for translations
- Use flexbox/grid that adapts to content size
- Use logical CSS properties (`margin-inline-start`, not `margin-left`)
- RTL support via `dir` attribute and `scaleX(-1)` for directional icons
- Use `Intl` API for date, number, and currency formatting
- Use proper i18n libraries for pluralization

### Error Handling

- Clear, specific error messages (not "Error occurred")
- Retry buttons for network failures
- Explanation of what happened and recovery path
- Inline form validation errors near fields
- Handle each HTTP status code appropriately:
  - 400: validation errors, 401: redirect to login, 403: permission error
  - 404: not found state, 429: rate limit message, 500: generic + support
- Core functionality works without JavaScript (graceful degradation)

### Edge Cases and Boundary Conditions

- **Empty states**: Helpful, with clear next action
- **Loading states**: Show what is loading, time estimates for long operations
- **Large datasets**: Pagination or virtual scrolling, search/filter
- **Concurrent operations**: Prevent double-submission, handle race conditions,
  optimistic updates with rollback
- **Permission states**: Clear explanation of access limitations

### Input Validation and Sanitization

- Required fields, format validation, length limits, pattern matching
- Server-side validation always (never trust client-side only)
- Protect against injection attacks, rate limiting
- Clear constraints communicated to users via `aria-describedby`

### Accessibility Resilience

- All functionality accessible via keyboard with logical tab order
- Proper ARIA labels, announce dynamic changes with live regions
- Descriptive alt text, semantic HTML
- Motion sensitivity: respect `prefers-reduced-motion`
- High contrast mode support, don't rely only on color

### Performance Resilience

- Progressive image loading, skeleton screens
- Optimistic UI updates, offline support (service workers where applicable)
- Clean up event listeners, cancel subscriptions, clear timers on unmount
- Abort pending requests on unmount
- Debounce search inputs, throttle scroll handlers

## Testing Strategies

- Test with extreme data (very long, very short, empty)
- Test in different languages and RTL
- Test offline and on slow connections (throttle to 3G)
- Test with screen reader and keyboard-only navigation
- Unit tests for edge cases, integration tests for error scenarios
- Accessibility tests (axe, WAVE)

## Verify Hardening

- **Long text**: Names with 100+ characters
- **Emoji**: Emoji in all text fields
- **RTL**: Test with Arabic or Hebrew
- **CJK**: Test with Chinese/Japanese/Korean
- **Network**: Disable internet, throttle connection
- **Large datasets**: 1000+ items
- **Concurrent actions**: Click submit 10 times rapidly
- **Errors**: Force API errors, test all error states
- **Empty**: Remove all data, test empty states

**NEVER**:

- Assume perfect input (validate everything)
- Ignore internationalization (design for global)
- Leave error messages generic
- Forget offline scenarios
- Trust client-side validation alone
- Use fixed widths for text content
- Block entire interface when one component errors
