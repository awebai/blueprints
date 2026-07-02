# aweb blueprints

First-party blueprints for aweb teams. Each top-level directory is one blueprint:
a catalog of role profiles a team can adopt into its private shelf, customize,
and run as a team of AI coworkers.

## Blueprints

- [`team/`](team/) — **aweb AI Team** (`aweb.team`): the default public
  blueprint — a complete team. A coordinator who plans and routes, developers
  and a reviewer who build and gate the work, agent-resources for identity and
  provisioning, and opt-in roles for frontend, copy, releases, and reliability.

Deprecated, pending removal from the catalog once `aweb.team` is the shipped
default: [`development/`](development/) and [`support/`](support/) — their
profiles are merged into `team/`.

## Blueprint layout

```
<blueprint>/
  blueprint.yaml       # blueprint id, version, the profiles it offers with
                       # recommended counts, expected apps, first-mission examples
  README.md            # what the blueprint is, for the person adopting it
  profiles/<id>/
    profile.yaml       # id, name, version, scope, mission, accepted_work, runtime, memory policy, skills
    instructions.md    # the profile's behavioral instructions
    skills/<s>/SKILL.md
    artifacts/*.md     # templates the profile ships with
```

A blueprint is published to Library via its canonical `import-payload.v1`
digest; adopting it copies the chosen profiles into a team's private shelf,
where the team evolves its own minted versions. Tags are set at publish time,
not in `blueprint.yaml`.

`shelf-notes/` holds org-specific notes stripped from public profiles, waiting
to be adopted onto our private shelf — see its README.
