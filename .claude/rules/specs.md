---
paths:
  - 'specs/**'
---

Before writing or changing a spec, read the "Specs" section of `AGENTS.md`. A new spec comes from the `spec-clarify` skill, in the format of the specs already in `specs/`; a spec whose work exceeds the PR size guide in `doc/rules/git-workflow.md`, or that mixes a runner or tooling change with new checks, is split into smaller specs before development starts, one pull request each. A delivered spec (its story merged) is never edited: record the change in the new spec and name the spec it supersedes.
