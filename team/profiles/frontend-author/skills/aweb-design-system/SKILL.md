---
name: aweb-design-system
description: Covers the aweb Paper/Clay design system - the tokens, dark mode, the shared header/footer chrome, the standard llms.txt split control, the component vocabulary, and the css distribution and verify-live model. Use when styling or reviewing any aweb page (a naapp or a Hugo site) so it matches across properties.
---

# The aweb design system (Paper/Clay)

A warm, paper-and-clay system: off-white "paper" background, terracotta accent
used sparingly, system fonts, thin rules and subtle surfaces, light + dark via CSS
variables. Every aweb property — the naapps (library, folio) and the Hugo sites —
shares the same `aweb.css` foundation and the same header/footer chrome so they
read as one family. This skill is how to use it correctly.

## Tokens (never hardcode a color or size)

- Background: `--bg` (#faf7f2 light / #0a0705 dark), `--bg-tint` (alternating
  section band), `--surface` / `--surface-2` (cards, code).
- Text: `--ink` (body), `--muted` (secondary), `--faint` (tertiary).
- Lines: `--line`, `--line-strong`.
- Accent: `--accent` (#b8482b light / #db6a45 dark), `--accent-soft`, `--accent-ink`.
- Status: `--ok` / `--wait` / `--run` / `--stop` (+ `-soft` variants).
- Radius `--radius` (14px) / `--radius-sm` (9px); shadows `--shadow-sm` / `--shadow-lg`.
- Spacing `--s1`…`--s8` (8px system); fluid type `--step--1`…`--step-4`.
- Fonts `--font-sans` / `--font-mono`; container `.wrap` (max 1120px).

Use the tokens for everything. A component built from tokens themes for dark mode
for free.

## Dark mode

Dark tokens are defined twice: under `:root[data-theme="dark"]` (manual toggle) AND
under `@media (prefers-color-scheme: dark) :root:not([data-theme="light"])` (OS
preference). Any component that uses `var(--token)` flips automatically — so write
component CSS in tokens and you get both themes. The one thing to add by hand:
outlined elements on the dark base often need a lifted border
(`rgba(255,255,255,0.30)`) — mirror the `.btn.secondary` dark override. **Always
screenshot dark mode**, don't assume.

## The shared chrome

Naapps get the chrome from the toolkit (`aweb_naapp.page(site, body)`): the head
(theme-color, the theme-init script, the css link), the sticky header (brand, nav,
theme toggle, header-right actions, the llms.txt control), the footer, and the
site scripts. An app supplies a `SiteConfig` (brand, nav, footer columns); the
chrome renders identically across naapps. Hugo sites reproduce the same header /
footer partials by hand (byte-consistent markup).

- Header is `position: sticky; top: 0`. If a page deep-links to sections, give the
  targets `scroll-margin-top` (~84px) so they clear it.
- `.theme-toggle` swaps a moon/sun icon by theme.

## The standard llms.txt split control

Every aweb page carries one standard control in the header — **last in
`header-right`, on every page**. A split button: the main area copies the page's
llms.txt to the clipboard (fetch → clipboard, checkmark + "Copied!" with no layout
shift); a caret opens an **opaque** dropdown (`--surface` + `--shadow-lg`, never
transparent — a hard requirement) with "Copy for LLMs" / "Open llms.txt". Labelled
`llms.txt` (honest — see the home-page skill's voice rules). Keyboard + aria wired
(caret `aria-expanded`, menu `role=menu`, arrow keys, Esc, outside-click close);
the caret collapses at 540px, the copy action stays.

- Naapps: it ships in the toolkit chrome (`_LLMS_CONTROL` markup + the split-btn
  handler in the site script + the `.split-btn` component in `aweb.css`),
  `data-llms-url` per page.
- Hugo sites: lift the same markup + JS + the `.split-btn` CSS block from the
  toolkit (or ac), byte-consistent, into the site-header / site-footer partials
  and the site stylesheet; wire `data-llms-url` to the page's llms.txt.
- This control REPLACES any dedicated "For LLMs / Read llms.txt" landing section —
  the header is the standard place.

## Component vocabulary

`.kicker` (mono uppercase accent label — the standard per-section eyebrow);
`.btn` `.primary` / `.secondary` / `.ghost` / `.btn--lg`; `.card` (surface + thin
border + radius); `.cmd` + `COPY_BTN` (a copyable code block — the site script
wires `.cmd .copy-btn`); `.section` + `.section--tint` (alternating bands);
`.wrap`. One terracotta accent per section, max — it's an entry point, not decoration.

## CSS distribution + the vendoring hazard

- The canonical `aweb.css` lives in the design-system source repo. The toolkit
  (`aweb-naapp`) vendors it and **sha-pins** it (`CSS_SHA256`, asserted by a test);
  naapps serve `aweb_css()` from the toolkit at `/css/aweb.css`. Hugo sites keep
  their own vendored copy (NOT byte-pure — they carry page-specific styles the
  naapps don't, so "strict superset" is not an invariant).
- When you change `aweb.css`: bump `CSS_SHA256`, regenerate any consuming app's
  goldens, and re-vendor the relevant copies.
- **Cross-checkout shadow:** consuming repos import the toolkit both as a pinned
  git dep AND via a pytest `pythonpath` to `../aweb-naapp/src`. The local source
  shadows the installed package — set `PYTHONPATH=../aweb-naapp/src` to preview
  local toolkit edits, and don't leave the shared checkout on a feature branch (it
  breaks teammates' main suites through the same shadow).
- **Re-pin ≠ redeploy.** Bumping an app's toolkit pin updates the source, but the
  *served* css only changes when the app's image is rebuilt. A naapp shipped with a
  stale image once served the pre-component css with 0 control rules while the
  branch was correct. After any deploy, curl the served css and confirm the
  component rules are present — and verify the live page (see below).

## Verify live — always

Tokens + a green build do not prove the rendered page. Screenshot light, dark, and
mobile during development; after deploy, open the real URL in a browser and look at
it. A golden byte-match passed while a page shipped completely unstyled. The build
is not the page.
