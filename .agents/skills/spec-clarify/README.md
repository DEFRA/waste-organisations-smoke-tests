# spec-clarify

Turns a Jira story, bug or idea into a spec in `specs/`, in the format the team already uses, by
asking you questions one topic at a time. It is the first step of every story in this repo: the
spec is what reviewers approve and what the Ralph build loop plans from.

The agent-facing procedure is in [SKILL.md](SKILL.md); this file is for developers.

## When to use it

- A new story is ready for refinement and needs a spec before development.
- A fault reached an environment unnoticed and the suite should have a check that catches it.
- An idea is still vague and you want it shaped into something actionable, or found to be too
  big for one spec.

## How to start it

| Tool        | How                                                                                      |
| ----------- | ---------------------------------------------------------------------------------------- |
| Claude Code | `/spec-clarify REGEN-NNN <one-line idea>`                                                |
| Codex       | `$spec-clarify` (or pick it from `/skills`), then give the story key and one line        |
| Either      | Ask in plain words: "write the spec for REGEN-NNN"; the skill loads from its description |

Have the Jira story text and its comments to hand. The agent cannot read Jira, so it will ask
you to paste what matters and will cite the story by its key.

## What happens

1. It reads `AGENTS.md`, the specs in `specs/`, the README table of checks and the spec files
   under `test/specs/`, then asks about the problem, who benefits, scope, the checks, risks,
   priority and size. Answer one topic at a time; say "don't know" where you don't and it
   becomes a risk or a next step in the spec.
2. For each check it settles the request, the credentials sent, the status that passes and what
   counts as a failure, then the conditions that must fail the suite.
3. It writes `specs/NNNN-REGEN-NNN-slug.md` with the standard sections: metadata table,
   Problem/Opportunity, Proposed Solution, Acceptance Criteria with Edge cases, Out of Scope,
   Notes.
4. It shows you the summary and adjusts until the spec says what you meant.
5. It tells you whether the work fits one pull request or needs splitting into smaller specs.

It never writes code, never touches another spec, and never edits a delivered spec; a change to
something an earlier spec decided is recorded in the new spec, naming that spec.

## What you get

A spec shaped like the one already in `specs/`:
[0001-REGEN-141-openapi-doc-smoke-tests.md](../../../specs/0001-REGEN-141-openapi-doc-smoke-tests.md).
Its table of checks, its acceptance criteria and its edge cases are the pattern to follow.

## Afterwards

- Open the spec as its own pull request when the team should review the plan before the code.
- If the work needs more than one pull request, write one spec per pull request.
- Start the Ralph loop or implement by hand; the review skills check the pull request against
  the spec's acceptance criteria.
