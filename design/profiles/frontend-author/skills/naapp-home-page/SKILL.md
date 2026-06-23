---
name: naapp-home-page
description: Captures how to write or rework a Native Agentic App (naapp) home/landing page in the aweb Paper/Clay system - the section structure, the content each section carries, the voice, the layout mechanics, and the verify-live process. Use when building, fixing, or reviewing a naapp landing page, especially a prose-wall or marketingese one.
---

# Writing a naapp home page

A naapp home page explains, to a developer and to an agent, what the app lets a
team *do* — concretely, scannably, and honestly. It is not a marketing page. The
default failure mode is a stack of dense prose paragraphs jammed into the left
half of the screen, full of jargon or vague superlatives. This skill is the
antidote, distilled from reworking library.aweb.ai section by section.

Read this whole file before editing. Then engage the `ux-design-guide` subagent
per section, and **verify the rendered page visually (Playwright) before calling
anything done** — see Process.

## Voice — the rules that matter most

The human will correct language harder than layout. Get these right first.

1. **Show, don't tell.** State what a team *does* with the app, not what the app
   "is." Hero headline = an action/outcome ("Where teams choose, keep, and
   improve the profiles their agents run"), never "X is a platform for Y."
2. **No marketingese, no meaningless phrases.** Banned: "actually real", "real
   work", "powerful", "seamless", "next-generation", and any headline that could
   sit on any product. If a phrase survives deletion without the section losing
   meaning, it was filler.
3. **Frame positively — what's possible, not what's broken.** Don't dwell on the
   bad old way ("a pasted prompt is unversioned…"). Say what the app gives ("a
   catalog of proven profiles you can adopt, share, and evolve"). The human's
   words: name the thing as *possible*, not as a deficiency list.
4. **Honest labels.** Call it `llms.txt`, not "Copy page". One llms.txt per app,
   not a per-page Markdown mirror — don't imply otherwise.
5. **De-jargon for the general sections; keep precise terms only where the
   audience expects them.** "canonical manifest, byte artifact, digest, native aw
   verbs, team certificate" → "a public manifest maps the whole API to `aw`
   commands." Precise terms (AWID, content digest, content-addressed) belong in
   the engineering section, whose readers want them.
6. **Tight. One idea per beat.** Cut any sentence that restates the one before.
   A right-column beat is one label + one sentence, not a paragraph.
7. **The engineering section may be terse and technical** — that's correct register
   for its audience (mono labels, one-word headings like "Invariants").

## Page structure

Sections in order. Each has a distinct *job* and — critically — a distinct
*layout*, so adjacent sections never read as twins. Alternate plain and
`section--tint` background bands.

### 1. Hero — what teams do, shown as a diagram
- Kicker: `NATIVE AGENTIC APP · <domain>.aweb.ai`.
- Headline: the action/outcome (see Voice #1). Big, ≤ ~8 words.
- **A diagram, not a prose lede.** Replace the explanatory paragraph with a clear
  inline-SVG model: the nouns + the flow + any human-gated loop (e.g. library's
  Catalog →(adopt)→ Shelf →(bind)→ Agent, with propose → human review → approve &
  mint as the one accented loop). Themeable (currentColor + `var(--accent)`),
  with a desktop and a vertical mobile variant, a one-line `<figcaption>`, and a
  full `role="img"` aria-label text alternative.
- CTAs: primary "Get started" (→ `#use`) + secondary "Read llms.txt".

### 2. "Why this exists" — the need, then what the app gives
- Layout: **two-column split**. Left = lead (kicker + a sharp headline naming the
  need + one tight paragraph). Right = a column of **three positive beats** ("What
  <app> gives you") separated by thin top-border rules, **one terracotta accent on
  the first rule only**. Fold the trust/foundation line (identity, signing) into
  the left column so both columns fill to similar depth (no floating void).
- Content: left states the need (e.g. "Agents need evolving job descriptions to
  work as a team"); right gives the three things the app makes possible
  (e.g. proven profiles to start from / build and share your own / start shared,
  evolve private). Positive framing.

### 3. "What it is" — plain definition + capability cards
- Layout: **a plain-language lead line + a 2×2 capability card grid** (cards on
  `--surface` with a thin border) + an **"in practice" callout** with a terracotta
  left border as the so-what. Cards, not beats — deliberately different from §2.
- Content: lead = one sentence a newcomer gets ("built for agents from the ground
  up: its whole API is part of the aweb protocol, so any agent or person can drive
  it without custom code"). Four cards = the concrete, de-jargoned capabilities
  (CLI-native API / events that wake agents / ships agent docs / verified by
  identity). Callout = the punchline (a person and an agent run the same commands).

### 4. Engineering section ("Invariants" / guarantees) — spec list
- Layout: **a spec/definition list** — `<dl>` with monospace term labels over thin
  rules, **no card boxes** (distinct from §2 beats and §3 cards). One-word heading
  ("Invariants"). A short contract lede ("these hold at every version, for every
  team"). One terracotta accent on the first rule.
- Content: the concrete guarantees as mono labels + one precise sentence each
  (`content-addressed`, `awid-signed`, `non-destructive merge`, `byte-reproducible`).
  Pull scope/limits out of the guarantee list into a subordinated `scope` note —
  a scope statement is not a guarantee.

### 5. Closing CTA band — end on an action
- A short centered statement + the primary/secondary CTAs, centered. A landing
  page ends on a call-to-action, never on a spec list or a dead band of buttons.

Plus, as the app needs: a getting-started/`#use` section (the `aw <verb>` install
commands) and a model section. The **/reference page is generated by the toolkit**
(`render_reference`) — see the reference, not the home page.

## Cross-section rules

- **Differentiate layouts.** §2 beats, §3 cards, §4 spec-list — never repeat a
  layout in adjacent sections. The UX subagent's first job each section: "make it
  visually distinct from the section above."
- **One terracotta accent per section, max.** It's the entry point (first rule,
  callout border). Kickers are already the standard accent — that's fine, it's
  the established per-section element. Don't scatter color.
- **No dedicated "For LLMs / llms.txt" section.** The standard `llms.txt` split
  control lives in the header on every page — that's the standard place. Delete
  any landing band that copies llms.txt.
- **No "bigger bet"-style vision section that restates the problem.** It twins
  with §2 and reads as filler. Cut it.
- **No dead half-width.** Every section uses the full width; the old failure was
  left-half prose with an empty right side.
- **Cut section blurbs that add no information.** A `.section-head` sub-paragraph
  that just paraphrases the heading is noise in a reference-grade page.

## Design-system mechanics (Paper/Clay)

Tokens (light, dark via tokens — never hardcode colors): `--bg` `--bg-tint`,
`--ink` `--muted` `--faint`, `--line` `--line-strong`, `--surface` `--surface-2`,
`--accent` (terracotta) `--accent-soft`, `--radius`/`--radius-sm`, spacing
`--s1`…`--s8`, fluid type `--step--1`…`--step-4`, `--font-sans`/`--font-mono`,
`.wrap` (container), `.kicker` (mono uppercase accent label).

- **App-specific section markup goes in a module-level string constant** (e.g.
  `_WHY_SECTION = """…"""`), interpolated into the page body as `{_WHY_SECTION}`.
  This is REQUIRED whenever the section has a scoped `<style>` or inline SVG: CSS
  `{ }` braces break the body f-string, but an already-built constant is inserted
  verbatim. Shared/reusable component CSS goes in the toolkit `aweb.css`.
- **Scope paragraph styles to their own class — never `.section p` / `.lead p`.**
  The kicker is a `<p>`; a broad `.parent p { margin-top: … }` rule silently
  pushes the kicker down and breaks column top-alignment. Give the lede its own
  class (`.why-need`, `.whatis-lead`). This bug cost real time — watch for it.
- **Even vertical rhythm.** Dividers get symmetric space above and below; balance
  two columns so neither leaves a floating gap; don't strand a right-aligned tag
  on wrap (group the tags in their own flex child, don't rely on `margin-left:auto`).
- **Responsive:** stack two-column splits to one column at ~880px (cards ~640–720px);
  give the hero diagram a separate vertical mobile SVG. The header `llms.txt`
  control's caret collapses at 540px.
- **Anchors under the sticky header:** if the page deep-links to sections, set
  `scroll-margin-top` (~84px) on the targets so they don't land behind the header.

## Process — and the rule that was learned the hard way

1. **One section at a time, with the human.** Show the current section, take the
   critique, engage `ux-design-guide` for a concrete redesign (telling it the
   layout of the section above so it differentiates), implement, render, show.
2. **Render to a static preview + Playwright + screenshot every change.** Render
   the surface to a temp dir, serve it, navigate, screenshot, and *read the
   screenshot*. Cache-bust the HTML (`?v=N`); the `/css/aweb.css` link isn't
   versioned, so force a fresh stylesheet load when iterating.
3. **Check light AND dark AND mobile.** All three, by construction (tokens +
   media queries) and by screenshot.
4. **VERIFY THE LIVE DEPLOYED PAGE — never trust goldens or deploy reports.**
   This is the cardinal rule. A byte-identical golden test passed and the deploy
   report said "done" while a folio page shipped completely unstyled (it was
   serving a stale aweb.css from an un-rebuilt image). Goldens prove the *build*;
   only opening the real URL in a browser proves the *page*. After any deploy,
   curl the served css (expect the component rules present) AND Playwright the
   rendered control/section. Do this for every app, every time.

## Anti-patterns (what a bad naapp landing looks like — and the fix)

- Prose-wall section, left-half only, empty right → full-width scannable layout
  (split/cards/spec-list).
- Jargon paragraph ("publishes a canonical manifest, a public byte artifact…") →
  plain lead + de-jargoned capability cards.
- Meaningless heading ("What's actually real") → name the substance ("Invariants").
- Dedicated "For LLMs and agents" band → the header control; delete the band.
- Vision section restating the problem ("today an agent's behavior is a pasted
  prompt…") → cut it (twins with "Why this exists").
- Headline that says what the app *is* → say what teams *do*.
- "Shipped" claimed from a green build → not shipped until the live URL is
  visually verified.
