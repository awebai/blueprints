# aweb blueprints

First-party blueprints for aweb teams. Each top-level directory is one blueprint:
a catalog of role profiles a team can adopt into its private shelf, customize,
and run as a team of AI coworkers.

## Blueprints

- [`engineering/`](engineering/) — **Engineering AI Team**: a
  coordinator, developers, and a reviewer that plan, build, and review real repo
  work as a team.

## Blueprint layout

```
<blueprint>/
  blueprint.yaml            # blueprint id, version, the profiles it offers, expected apps
  README.md            # what the blueprint is, for the person adopting it
  missions.yaml        # example first missions
  profiles/<id>/
    profile.yaml       # mission, accepted_work, runtime, memory policy, skills
    instructions.md    # the profile's behavioral instructions
    skills/<s>/SKILL.md
    artifacts/*.md      # templates the profile ships with
```

A blueprint is published to Library via its canonical
`import-payload.v1` digest; adopting it copies the chosen profiles into a team's
private shelf, where the team evolves its own minted versions.
