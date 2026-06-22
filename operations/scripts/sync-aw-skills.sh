#!/usr/bin/env bash
# Sync the canonical aweb-agent-instantiation skill from the aw repo into the
# coordinator and agent-resources profiles.
#
# The skill is aw mechanics (materialize, run, onboard, and retire an agent), so
# its single source of truth lives in the aw repo. It is scoped to the two roles
# that own staffing — coordinator and agent-resources — rather than shipped in
# the universal aweb-skills plugin every agent installs. Re-run this and
# re-publish the blueprint whenever aw changes the instantiation mechanics.
#
#   AW_REPO  path to the aw repo   (default: ~/prj/awebai/aweb)
#   AW_REF   git ref to sync from  (default: origin/main)
set -euo pipefail

AW_REPO="${AW_REPO:-$HOME/prj/awebai/aweb}"
AW_REF="${AW_REF:-origin/main}"
SKILL="aweb-agent-instantiation"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for profile in coordinator agent-resources; do
  dest="$ROOT/profiles/$profile/skills/$SKILL"
  mkdir -p "$dest"
  git -C "$AW_REPO" show "$AW_REF:skills/$SKILL/SKILL.md" > "$dest/SKILL.md"
  echo "synced $SKILL -> profiles/$profile/skills/$SKILL/SKILL.md"
done
