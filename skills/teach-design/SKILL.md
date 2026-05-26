---
name: teach-design
description: >-
  One-time project setup that gathers design context and saves it to
  DESIGN.md. Run once per project to establish persistent design
  guidelines used by all Atlas design skills.
---

<!-- Adapted from pbakaus/impeccable (Apache 2.0) -- see NOTICE.md -->

One-time setup skill. Run this when starting design work on a new project, or
any time the design context in `DESIGN.md` is missing, stale, or
incomplete. All Atlas design skills depend on this context to avoid generic
AI aesthetics and produce project-specific output.

## Step 1: Explore the Codebase

Silently read the codebase to gather initial context before asking questions.
Inspect ALL of the following that exist -- do not stop at the first match:

1. `README.md` and any other top-level or `docs/` documentation -- product
   description, purpose, target audience
2. `package.json`, `pyproject.toml`, `Cargo.toml`, or equivalent -- tech
   stack, dependencies, product name
3. Component directory (e.g. `src/components/`, `app/components/`) -- UI
   patterns already in use; note recurring visual patterns, naming, structure
4. Brand and style documentation: `STYLEGUIDE.md`, `brand.md`,
   `docs/brand/`, or equivalent -- explicit brand standards, color values,
   typography choices, voice and tone guidelines
5. Design tokens and CSS variables: `tokens.*`, `theme.*`,
   `variables.(css|scss|less)`, `tailwind.config.*` -- actual color, spacing,
   and type values in use
6. Brand assets: `logo.*`, `favicon.*`, `public/`, `assets/` -- icon style,
   illustration style, visual language
7. Any existing design instructions: `DESIGN.md`,
   `AGENTS.md` -- note any prior design context that
   may already be established

Synthesize everything found. Record conflicts or gaps. Do NOT ask questions yet.

## Step 2: Ask UX-Focused Questions

Ask the user the following questions. Only include questions not already
answered by the codebase exploration in Step 1:

**Users & Purpose**

- Who are the primary users of this product?
- What is the single most important action a user should be able to take?
- What feeling should the product leave users with?

**Brand & Personality**

- Does this product have an existing brand (colors, fonts, logo, tone)? If yes,
  describe it.
- Which of these tones best fits the product: serious/professional,
  approachable/friendly, playful/energetic, minimal/efficient,
  premium/luxurious?
- Are there products or designs you admire that share a similar personality?

**Aesthetic Preferences**

- Any visual styles to explicitly avoid?
- Any styles or aesthetics you want to lean into?

**Accessibility**

- Are there specific accessibility requirements (WCAG level, user demographics
  with visual or motor constraints)?

Ask all applicable questions in a single message. Wait for the user's response
before proceeding to Step 3.

## Step 3: Write Design Context

Synthesize your Step 1 findings and the user's Step 2 answers into a concise
`## Design Context` section and write it to `DESIGN.md` at the project
root.

- If `DESIGN.md` does not exist: create it with the `## Design Context`
  section as the sole content.
- If `DESIGN.md` already exists: replace the existing `## Design Context`
  section in place. Do not overwrite unrelated content in the file.

The section must follow this exact format:

```markdown
## Design Context

**Product:** [Product name and one-sentence description]

**Users:** [Primary user group and their key goals]

**Brand:**

- Colors: [specific values if known, or descriptors]
- Fonts: [specific values if known, or descriptors]
- Tone: [chosen tone from Step 2]

**Aesthetic direction:** [1-3 sentences describing the intended visual
personality. Be specific -- name a design movement, reference, or archetype.]

**Hard constraints:**

- [Any explicit avoid rules from Step 2]
- [Accessibility requirements]

**Inspired by:** [Products or styles the user named, if any]
```

After writing `DESIGN.md`, sync to `AGENTS.md`:

- If `AGENTS.md` does NOT exist: create it and append
  the `## Design Context` block so design context is automatically active in
  every Copilot interaction.
- If it exists but does NOT contain a `## Design Context` section: append the
  block.
- If it ALREADY contains a `## Design Context` section: replace that section
  in place with the newly synthesized content. Do not leave stale design
  context in the auto-loaded instructions file.

Confirm what was written and where. Inform the user that all Atlas design
skills will now use this context automatically.
