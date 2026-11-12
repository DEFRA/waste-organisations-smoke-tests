---
name: spec-clarify
description: >
  Turn a Jira story, bug or rough idea for this smoke test suite into a spec in specs/, in the
  repo's spec format, by asking the author questions one topic at a time: problem, scope, the
  checks and their acceptance criteria with the conditions that must fail the suite, risks,
  priority, size. Writes specs/NNNN-REGEN-NNN-slug.md and nothing else; never implements and never
  edits a delivered spec. Use whenever asked to write, draft, refine or clarify a spec or story,
  for example "/spec-clarify REGEN-NNN ...", "/clarify", "write the spec for REGEN-NNN", "turn
  this story into a spec", "refine this idea".
---

# Spec clarify

This skill produces a spec in the format this repo already uses. The format reference is the
spec in `specs/`: `specs/0001-REGEN-141-openapi-doc-smoke-tests.md`. Read it before writing.

You are running an idea refinement workshop with the developer. The output is a spec that a
reviewer can approve and that the Ralph build loop, or a developer, can implement without
asking the author what was meant.

## Usage

`/spec-clarify REGEN-NNN <one-line idea>` in Claude Code, or `$spec-clarify` in Codex. Without
an argument, ask for the story key and a one-line description first. If the work has no Jira
story, say so in the spec; never invent a key.

## Ground rules

- **Ask, do not assume.** Work through the phases below one topic at a time, in chat, offering
  options where you can and waiting for the answer. Use the tool's question facility if it has
  one; plain questions in chat are fine otherwise.
- **Read before asking.** Read `AGENTS.md` (especially "Smoke checks" and "Specs"),
  `doc/rules/quality-assurance.md`, the latest specs in `specs/` for format and prior decisions,
  the README table "What the suite checks", and the spec files under `test/specs/`. Confirm what
  the suite already checks before calling anything missing.
- **Sources are referenced, not pasted.** Ask the author to paste the Jira story text and
  comments if you cannot read them; cite a Jira story by its key and a pull request in another
  repository by its link. Never put credentials or personal data into the spec.
- **Specs only.** Write one file under `specs/`. Do not change code, configuration or any other
  spec. A delivered spec (one whose story is merged) is never edited: a change to something it
  decided is recorded in the new spec, with the earlier spec named (`AGENTS.md`, "Specs").
- **Testable means testable here.** Every acceptance criterion is a check against a deployed
  environment, or a statement about a run of the suite, that someone can observe: a request, the
  credentials sent, the status that passes, an exit code, a line in the report.

## Phases

### 1. Understand

Establish: the problem or opportunity, who benefits (the delivery team, the teams that consume
the API, operations), what triggered it (often a fault that reached an environment unnoticed),
and what success looks like. For a fault, record what was observed, in which environment, the
root cause if known and where it was fixed. Then read the suite and record what it already
checks, with file names.

### 2. Classify

Feature (a new check or group of checks), Bug (a check that passes or fails wrongly),
Improvement, Spike (time-boxed research, for example whether a host is reachable from a CDP test
suite run), Task (runner, image or tooling work with no change to what is checked), or Epic. An
Epic is not one spec: say so, and agree with the author which smaller story to write up first.

### 3. Scope

What is in, what is explicitly out, what the minimum is. A smoke check confirms the service is
up and serving; it does not test functionality or validate content
(`doc/rules/quality-assurance.md`). Push anything beyond that into Out of Scope and name where
it belongs. Ask about anything an earlier spec decided that this work would change; record the
change in this spec and name the superseded spec.

### 4. The checks

For each check, settle the four parts and write them as a table row, as the existing spec does:

| Part        | Ask                                                                                    |
| ----------- | -------------------------------------------------------------------------------------- |
| Request     | Method and path, including the query string.                                           |
| Credentials | None, or which credential, named by the environment variable CDP supplies it in.       |
| Expected    | The one status that passes.                                                            |
| Failure     | Confirm the defaults: no redirects followed, any other status, network error, timeout. |

Then settle: the target host (the public API host unless the story gives a reason), which
environments the check is expected to pass in and any where it is expected to fail, and how the
run is triggered.

### 5. Acceptance criteria

Three to twelve criteria, each one line, each observable. Write them as checkboxes under
"Acceptance Criteria", then the negative cases under "### Edge cases":

- **Positive criteria** are checks against a deployed environment ("`GET /openapi/v2.json` with
  no credentials returns `200` and its test passes"), plus the criteria about the run itself
  (passes from the CDP Portal against a named environment, exits `0`, no environment URL
  hard-coded, README table updated, the gate passes).
- **Negative cases are the conditions that must fail the suite.** For every check ask: what does
  a broken deployment look like here? A `401` from the gateway, a redirect to a login page, an
  unreachable host, a timeout. Each becomes an edge case that says it is a failure and what the
  message reports.
- Say what a passing check does **not** prove, where that matters (the existing spec does this
  for the ReDoc page), so nobody over-trusts a green run.

Bugs get current behaviour, expected behaviour, steps to reproduce and impact in
Problem/Opportunity, and a criterion that the bug no longer occurs.

### 6. Risk and dependencies

Unknowns, risky areas (reachability from CDP, the platform proxy, gateway routes owned by another
repository, environments without the route), dependencies on other stories or teams, and a risk
level (low, medium, high) with the reason. For high uncertainty, propose a spike spec first.
What can only be confirmed by a run from the CDP Portal after merge goes under "Next steps".

### 7. Priority

P0 critical (blocking), P1 high, P2 medium (default), P3 low, P4 backlog, with the rationale in
Problem/Opportunity ("Why P1: ...").

### 8. Size

Estimate the pull requests the work needs. A spec is one pull request when its non-generated
change stays within the size guide in `doc/rules/git-workflow.md` and mixes no unrelated concerns
(a runner or tooling change, new checks, documentation). If it needs more, say so and agree
with the author how to split the work into smaller specs, one pull request each, before writing.

### 9. Write the spec

Path: `specs/NNNN-REGEN-NNN-slug.md`, where `NNNN` is the next number after the highest in
`specs/` and the slug comes from the story title (`specs/NNNN-slug.md` when the work has no Jira
story). Use this structure, with the section headings exactly as written:

```markdown
# NNNN – REGEN-NNN – Title

| Field    | Value                                      |
| -------- | ------------------------------------------ |
| Ticket   | REGEN-NNN (or "none", with the reason)     |
| Type     | Feature / Bug / Improvement / Spike / Task |
| Priority | P0 (Critical) to P4 (Backlog)              |
| Risk     | Low / Medium / High                        |
| Status   | Draft / In progress / Delivered            |
| Date     | Day Month Year                             |

## Problem/Opportunity

## Proposed Solution

(the table of checks: request, credentials, expected; then bullets for the target host, the
trigger, failure semantics and anything about the runner or image)

## Acceptance Criteria

- [ ] one line per criterion

### Edge cases

- one line per condition that must fail the suite, or per limit of what a pass proves

## Out of Scope

## Notes

### Risks and uncertainties

### Next steps
```

British English, absolute dates, no pasted sources, no personal data. The Ticket row carries the
Jira key only. Keep the Proposed Solution concrete enough to implement from: paths, statuses,
variable names, file names that follow `doc/rules/javascript-nodejs.md`. Add further `###`
sections under Notes when the story needs them, as the existing spec does for running on CDP.
Run `npm run format` so the tables match the formatter, then `npm run format:check`.

### 10. Present and confirm

Show the author the type, priority, title, the table of checks, the acceptance criteria with the
edge cases, and the open risks, and ask whether the spec says what they meant. Adjust until it
does.

### 11. Next steps

Say which applies: the spec is one pull request and development can start; it is too big
for one pull request and needs splitting into smaller specs; it needs a spike first; or an unknown blocks it and who can answer it. A spec
can be reviewed as its own pull request before implementation starts; recommend that when
the plan itself needs the team's agreement.

## Do and do not

Do:

- Push for concrete, observable criteria and for the conditions that must fail the suite.
- Make exclusions explicit; Out of Scope is where scope creep is stopped.
- Name the earlier spec whenever a decision changes something it decided.
- Record why a decision was made (for example why the public host and not the internal one), so
  the spec is a record, not just a plan.
- Keep the spec within one pull request; split bigger work into smaller specs.

Do not:

- Accept vague criteria ("check the API works", "make the suite more robust").
- Skip the "why"; the Problem/Opportunity section is what a reviewer judges the solution against.
- Turn a smoke check into a functional or contract test.
- Edit a delivered spec, or paste its text into the new one.
- Start implementing, create branches, or change anything outside `specs/`.
- Invent Jira keys, dates, URLs or decisions; ask.
