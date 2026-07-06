---
name: manage-profiles
description: >-
  Manages a team's role profiles through the library plugin - adopt a public
  blueprint profile, author one from scratch, evolve it on the private shelf,
  pull upstream improvements without losing team edits, and publish back to the
  catalog. Use when creating, specializing, versioning, or publishing a profile
  or a whole blueprint, or when setting up the library plugin for a team.
---

# Manage profiles

The library holds the team's role profiles. A profile lives first on the team's
**private shelf**, where you author and evolve it; from there you **publish** it
into a **public blueprint** other teams can adopt. Every step is a library plugin
verb, authenticated by the team certificate's `library:write` scope — any team
member whose cert holds that scope can do this; it is not gated to one role.

The exact flags for each verb come from the installed Library plugin manifest;
check each tool's `input_schema.required` fields and pass values by flag or
`--body-file`, never as bare positionals.

## Setup: install the plugin

The library exposes its API as manifest-dispatched Library subcommands. Install
it once into the trusted plugin directory, then confirm the verbs are present:

```
aw plugin install <library manifest>
aw plugin list
```

Calls authenticate with the team cert (`aw id request --team-auth`); the team is
taken from the cert, never passed. `aw library register` (once, idempotent;
optional `--owner` / `--display_name`) binds the team to the library.

## The two homes: shelf vs public blueprint

- **Shelf** — the team's *private* profile store. Yours to author, version, and
  evolve freely; invisible to other teams.
- **Public blueprint** — the *catalog* entry other teams adopt. A profile reaches
  it only by being **published** from the shelf (or imported whole).

## Create a profile

Two starting points.

**Author from scratch** — `aw library create-shelf-profile --body-file <profile.json>`. The body carries the required `files` array (`profile.yaml`, `instructions.md`, and each `skills/<s>/SKILL.md`) plus optional tags. It lands on the shelf as version 1.

**Adopt and specialize an existing one** — `aw library import-to-shelf --source_blueprint_ref <blueprint_ref> --profile_ref <profile_ref>` (optionally `--source_blueprint_version <v>`). This copies a public-blueprint profile onto the shelf under its source ref and records that source — the path for "start from a generic catalog profile, then make it ours." Re-importing the same source is a no-op; it never pulls a newer version (that is `update-from-source`).

## Evolve it

`aw library shelf-version --profile_ref <profile_ref> --body-file <profile.json>` adds a new content version from the new required `files` array. Source provenance, tags, and per-part baselines carry forward.

## Track the source — the asset-scoped loop

When the generic profile you adopted improves upstream, pull those improvements
without losing your edits:

`aw library update-from-source --profile_ref <profile_ref> --target_version <v>` is a Library plugin verb (manifest-dispatched after `aw plugin install`; optionally add `--source_blueprint_version <v>`). It runs a **per-part 3-way merge** — pulling upstream changes only into the parts you have **not** edited on the shelf, and never clobbering a part you have evolved. A real merge mints the target version and advances the source pin; if nothing is pullable it is a no-op. This is how an adopted profile stays current with its generic base while keeping our specializations.

## The learning gate: propose / approve

Reviewed learning operates on the **shelf** profile, not on public blueprints:

- `aw library propose --target profile --profile_ref <profile_ref> --body-file <proposal.json>` — submit a profile-targeted proposal; asset changes (file and `profile.yaml`-field assets) live in the body content. `--profile_ref` is optional only when the proposal body supplies it.
- `aw library proposals` — list open proposals.
- `aw library approve --proposal_id <proposal_id>` — apply it; auto-bumps the
  next patch version after per-asset stale checks.
- `aw library reject --proposal_id <proposal_id>` — drop it.

Use this when a profile should evolve **under review** rather than by a direct
`shelf-version` write — the agent proposes, a reviewer approves.

## Apply the approved version to a running home

A proposal approval or `update-from-source` merge mints a new shelf profile
version, but a public-pinned agent home keeps following the public catalog until
you adopt it onto the team shelf. Close the loop in order:

```bash
aw team adopt <name>
aw library propose --target profile --profile_ref <profile_ref> --body-file <proposal.json>
aw library approve --proposal_id <proposal_id>
aw team refresh <name>
```

`aw team adopt <name>` is the bridge: it reads the public profile pin in the
home, imports that profile onto the team's private Library shelf, binds the
agent, and re-points `.aw/profile/ref.json` to the shelf copy. Adopt **before**
you expect propose/approve/refresh to reach the running agent.

After adopt, `aw team refresh <name>` reads the home's shelf pin, pulls the
latest shelf version for that profile, and re-materializes the home. It prunes
the managed set, preserves home state outside that set, updates
`.aw/profile/ref.json`, and is a no-op when the digest is unchanged. The Library
plugin is required for `aw team adopt`'s shelf import and for the Library
evolution verbs.

Public-pinned homes still have a valid refresh path: they refresh from the latest
published version of their public blueprint source. That is the upstream catalog
improvement path, not the team-local shelf learning loop.

If you are pulling upstream blueprint improvements into the shelf, install/use
the Library plugin and do that before refresh:

```bash
aw library update-from-source --profile_ref <profile_ref> --target_version <v>
aw team refresh <name>
```

Without adopt plus refresh, the approved improvement exists on the shelf but the
live public-pinned agent keeps running the previous public-source home.

## Publish to the catalog

Two ways a profile reaches a public blueprint.

**Promote one shelf profile** — `aw library publish-profile --profile_ref <profile_ref> --blueprint_version <v>`, with optional `--profile_version <v>`, `--target_blueprint_ref <ref>`, or `--body-file <new-blueprint.json>`. The library generates the `blueprint.yaml`; the published profile keeps its shelf digest; the blueprint's profile set accumulates.

**Import a whole blueprint at once** — `aw library publish-blueprint --body-file <import-payload.json>`, body = the canonical `import-payload.v1` (required `files` + `schema`). This is the **first-party / repo-source** path: hand-author a blueprint in a repo, build its canonical import payload, import the whole thing. Idempotent on (owner_team, blueprint_ref, version).

## Materialize an agent from a profile

`aw library materialize --profile_ref <profile_ref> --runtime_kind <kind> --target local` produces a runnable local home — composed `AGENTS.md`, installed skills, the profile under `.aw/profile/` — from a shelf or catalog profile. `--target` is the materialization target kind (`local` or `custodial-mcp`); include `--agent_id <agent_id>` instead of `--profile_ref` when materializing from an agent binding. It is the library-side counterpart to the souls / `aw init` path.

## Tags and binding

- `aw library set-profile-tags --profile_ref <profile_ref> --body-file <tags.json>` — discovery tags on a shelf profile; the body carries the required tags array.
- `aw library bind --agent_id <agent_id> --profile_ref <profile_ref> --profile_version <v> --profile_digest <sha256>` / `aw library get-binding --agent_id <agent_id>` — bind an agent to a profile, and read the binding.

## Guardrails

- Authoring and shelf evolution are private; **publishing** makes a profile
  public — treat `publish-profile` / `publish-blueprint` as the outward-facing
  step, with the care any outward action deserves.
- Prefer `update-from-source` over re-adopting to pull upstream — re-import never
  pulls a newer version by design.
- Prefer `propose`/`approve` (reviewed) when a change is learning the team wants
  to keep; use `shelf-version` for direct authoring.
- The canonical `import-payload.v1` digest is the identity of a published
  blueprint; keep the source that generates it under version control.
