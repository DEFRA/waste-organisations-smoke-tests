---
paths:
  - 'specs/**'
---

Before writing or changing a spec, read the "Specs" section of `AGENTS.md`. A new spec comes from the `spec-clarify` skill, in the format of the specs already in `specs/`, and always has a Work breakdown, with a single slice when the work is one pull request; a spec whose work exceeds the PR size guide in `doc/rules/git-workflow.md`, or that mixes a runner or tooling change with new checks, stays one spec and is sliced in its Work breakdown, one pull request per slice. A delivered spec (its story merged) is never edited: record the change in the new spec and name the spec it supersedes.
