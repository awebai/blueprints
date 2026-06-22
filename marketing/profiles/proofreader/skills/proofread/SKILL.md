---
name: proofread
description: Reviews marketing copy and rendered web pages before they ship and returns a verified ship-or-amend verdict with quoted findings and fixes. Use when proofreading copy (emails, ads, posts, landing pages) or reviewing a web page before it goes live.
---

# Proofread

Read a piece of copy or a web page and return a clear, verified ship-or-amend
verdict.

## Steps

1. **Get the goal.** Know who the piece is for and what it should make them do
   or feel before you judge a single word. If that is unclear, ask.
2. **Read it once, whole, fresh.** Get the overall impression - does it land, is
   it clear, does it sound on-brand - before you nitpick lines.
3. **For a web page, open the rendered page.** Read the real page, not just the
   copy: the headline you see first, the call to action, what is above the fold,
   how it reads on a small screen. If the playwright MPC is installed use it.
   You may have to run the server, if so ask for permission.
4. **Go dimension by dimension:**
   - Correctness - spelling, grammar, punctuation, typos.
   - Clarity - clear on first read, no jargon or padding, scannable.
   - Consistency - terms, names, capitalization, numbers, formatting.
   - Accuracy - verify every claim, number, name, price, date; follow every link.
   - Voice and tone - on-brand, right for the audience.
   - Structure (pages) - headline, hierarchy, call to action, the eye's path.
   - Accessibility - alt text, heading order, descriptive link text, reading level.
5. **Verify each finding.** Confirm the rule, follow the link, check the claim
   against a source, confirm the style guide before you flag a deviation.
6. **Sort findings** into blocking (errors, wrong/broken links, misleading or
   non-compliant claims, meaning-changing mistakes, off-brand tone, accessibility
   failures) vs. optional (preferences, tightening, word choice).
7. **Return the verdict.** Ship, or amend-before-publishing with each blocking
   item quoted and its fix. Keep optional suggestions in their own section.

## Calibration

- A factual error, wrong number, or broken link is always blocking - never
  "minor."
- A style preference is never blocking - offer it, don't gate on it.
- Unsure if it's wrong? Say so and explain the risk; don't assert a correction
  you haven't verified.

## Guardrails

- Quote the exact text for every finding so the writer can act without guessing.
- Flag and suggest; do not rewrite whole passages unless asked.
- Verify before flagging - a wrong correction costs more than a missed nit.
- Route brand and strategy calls (is the message itself right?) to the campaign
  owner, not yourself.
