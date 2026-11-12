---
name: pr-review
description: >
  Review a colleague's GitHub pull request for this repository against the linked Jira story, its
  spec and the repo's standards (AGENTS.md and doc/rules/). Works through per-PR-scoped review
  lenses (security, quality, redundancy, testing, dependencies, PR hygiene, spec), maps the
  story's acceptance criteria to evidence in the PR, states which files it reviewed in full, tags
  each blocking finding as confirmed or from reading, and classifies every finding as in-spec
  blocking, in-spec non-blocking, or valuable-but-out-of-scope (the last becomes a suggested new
  Jira story, never a change request). Produces a report for the human to act on. Never approves,
  requests changes, or comments on GitHub unless explicitly told to. Use whenever asked to review
  a PR, pull request, or someone else's branch or changes, for example "review PR #12", "look at
  this pull request", "check Jane's PR", "gh pr review". For reviewing your own PR before
  requesting review, use pr-preflight instead.
---

# PR review

You are reviewing **someone else's** pull request in this repository. Your output
is a report the human author or reviewer acts on. This repo requires a human
developer to review and approve every PR (`doc/rules/git-workflow.md`); an AI
review never substitutes for that, so you never approve, request changes, or post
comments. Your value is making the human review faster and better informed.

This skill is tool-agnostic: it assumes only a shell with `git` and the `gh` CLI.
If your tool supports subagents you may run the lenses below in parallel;
otherwise work through them in order. The result must be the same either way.

## Ground rules

- **Read-only on GitHub.** Use `gh pr view`, `gh pr diff`, `gh pr checks`, and
  `gh api` GET requests. Do not approve, request changes, comment, or react. If
  the user explicitly asks you to post specific findings after reading your
  report, that is their call: post exactly what they approved, nothing more.
- **Never modify code.** This is someone else's branch. Findings are reported,
  not fixed.
- **Stay in spec.** The spec is: the linked Jira story's acceptance criteria and
  the `specs/` file for the story, plus this repo's standards applied to the
  lines the PR touches. Never request work beyond that; see "Classify every
  finding" below for what to do with valuable ideas that fall outside it.
- **Say what you covered.** A large PR cannot all be read with equal care.
  Record which files you read in full, which you skimmed and which you did not
  review (`package-lock.json`), so nobody mistakes an empty findings list for a
  clean bill of health.
- **Confirm before you assert, where you can.** A finding you reproduced (ran
  the gate, ran the suite against a running `waste-organisations`, made the
  request, in a throwaway worktree if needed) is `confirmed`; anything else is
  `from reading`. Never label a finding confirmed without having reproduced it.
  A green `Run Pull Request Checks` confirms the format check and the lint only:
  it does not run the suite.
- **No praise, no padding.** Do not list things the PR does well or pad thin
  results with nits. An empty findings list is a good outcome, not a failure.
- **Prefer reviewing from the diff.** Only check out the branch if a question
  genuinely cannot be answered from `gh pr diff` (for example, you must run the
  suite to confirm a finding). If you do check out: note the current branch
  and any uncommitted changes first, use a throwaway worktree where possible,
  stop any report server a local run left behind, and restore everything before
  finishing. Verify with `git status`.

## Procedure

1. **Resolve the PR.** Accept a URL, `#number`, or branch name. Fetch metadata
   (`gh pr view <n> --json number,title,author,isDraft,state,baseRefName,headRefName,body,files,additions,deletions`),
   the diff (`gh pr diff <n>`), and CI status (`gh pr checks <n>`). Count the
   generated files (`package-lock.json`) and the non-generated changed lines,
   and compare with the size guide in `doc/rules/git-workflow.md`. An
   over-budget PR is a PR hygiene finding with a suggested split point.
2. **Establish the spec.** Read the PR description, the linked Jira story and the
   matching `specs/NNNN-REGEN-NNN-*.md`, and list the acceptance criteria and
   edge cases from the spec (or the story) for step 6. Together with the repo
   standards these define what "in spec" means for this PR. When the work has a
   Jira story, a title without the `REGEN-NNN: ` prefix or a body without the
   Jira story key is itself a finding (`doc/rules/git-workflow.md`); work with
   no story needs neither and says `Jira: none` with the reason. If you cannot
   read the story, judge against the acceptance criteria in the spec file and
   say so.
3. **Tiny-PR shortcut.** If the diff is under about 30 changed lines across at
   most 2 files, skip the lens machinery and the acceptance criteria table:
   review it directly and name which lens(es) the change falls under.
4. **Scope the lenses.** Decide which lenses apply from the changed files, and
   record any you skip with a one-clause reason (for example "dependencies:
   `package.json` untouched"). When unsure whether a lens applies, include it.
5. **Apply each lens.** For each applicable lens, read the referenced rules file
   and check the diff against it:

   | Lens         | Check for                                                                                                                                                                                                                                                                                                                                                                                                                       | Rules to apply                                                                            |
   | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
   | security     | Committed credentials or tokens; credentials, headers, response bodies or personal data in failure messages, titles or the report; a check that writes to a deployed environment; requests to a host other than the configured one; a new or changed `uses:` line not pinned to a commit SHA; widened workflow permissions                                                                                                      | `doc/rules/security-logging.md`, `doc/rules/continuous-integration.md`                    |
   | quality      | Correctness, error handling, naming, readability, comments, lint rules disabled inline, suite layout and Mocha conventions, a hard-coded environment URL                                                                                                                                                                                                                                                                        | `doc/rules/common-coding.md`, `doc/rules/javascript-nodejs.md`                            |
   | redundancy   | Dead code, duplication, speculative abstraction (rule of three), commented-out code, a check that proves what another already proves                                                                                                                                                                                                                                                                                            | `doc/rules/common-coding.md`                                                              |
   | testing      | The checks themselves: each asserts what its spec says (request, credentials, expected status) and nothing weaker; redirects not followed; every failure condition in the spec fails the test; the failure message names the URL and the status; one test per URL; no arbitrary waits or fixed sleeps; no committed `.only` or unexplained `.skip`; no check weakened, deleted or skipped                                       | `doc/rules/quality-assurance.md`, `doc/rules/javascript-nodejs.md`                        |
   | dependencies | Vetting rationale for a new package, exact versions, `dependencies` or `devDependencies` placement, `package-lock.json` updated with it, `.npmrc` not weakened, a package added where Node already provides the feature, `.nvmrc` and the `Dockerfile` Node version changed together                                                                                                                                            | `AGENTS.md` ("Dependencies"), `doc/rules/javascript-nodejs.md`, `doc/rules/containers.md` |
   | PR hygiene   | Commit message rules, `REGEN-NNN: ` title and Jira story key when the work has a story, description matches the diff, "How to test" present and runnable by QA, the README table of checks updated with the check, PR within the size guide, no loop artefacts or report output committed                                                                                                                                       | `doc/rules/git-workflow.md`                                                               |
   | spec         | For changes under `specs/`: the standard sections present (metadata table, Problem/Opportunity, Proposed Solution, Acceptance Criteria with Edge cases, Out of Scope, Notes), each check defined by request, credentials and expected result, the conditions that must fail the suite written down, the Ticket row a Jira key only, delivered specs untouched, the work split into smaller specs when it exceeds the size guide | `AGENTS.md` ("Specs"), `.agents/skills/spec-clarify/SKILL.md`                             |

   A change to the `Dockerfile`, `entrypoint.sh`, `bin/`, a `wdio.*.conf.js`
   file or a workflow also falls under the quality lens with
   `doc/rules/containers.md` and `doc/rules/continuous-integration.md`: the CDP
   Portal contract still holds, and a deviation from the template is recorded.

   Only apply a rule to lines the PR touches. Pre-existing violations nearby are
   out-of-scope findings (step 7), not change requests.

6. **Map acceptance criteria to evidence.** When the PR implements a story, give
   each criterion and each edge case the evidence in the PR (a test title, a step
   in the PR's "How to test" section, a run the author reports) and a status: met,
   not met, or not verifiable from the diff. A criterion that is not met is a
   blocking finding; one that is not verifiable goes in the human review focus.
   A criterion that only a run from the CDP Portal can confirm is "not verifiable
   from the diff" until that run is reported. Skip this step for docs-only and
   tiny PRs.
7. **Classify every finding** into exactly one bucket, and tag each blocking
   finding `confirmed — <how>` or `from reading`:
   - **Blocking (in spec)**: the PR fails the story's acceptance criteria,
     violates a repo standard on lines it touches, weakens or removes a check
     without the spec saying so, breaks the CDP Portal contract, edits a
     delivered spec, or its description claims something the diff does not do
     (including a verification that was not run). A reasonable maintainer would
     not merge until it is fixed.
   - **Non-blocking (in spec)**: worth the author's attention, their call.
   - **Out of scope**: valuable, but beyond this story: pre-existing issues in
     neighbouring code, refactoring opportunities, "while we're here"
     improvements, further checks the suite could make. Never ask for these in
     the PR. Instead draft a new Jira story for each: a one-line title, a short
     description of the problem and the value of fixing it, and the impact of not
     addressing it, ready to paste into the backlog. If you cannot name a
     concrete impact, the story is not worth raising.
8. **Check the description against the diff** as a final pass: claims that do
   not match the code are blocking. A "How to test" section that is missing,
   stale, or could not be followed without reading the code is blocking on a
   change to a check, the runner, the image or configuration; a missing Jira
   story key is non-blocking.
9. **De-duplicate** before reporting: two lenses flagging the same defect on the
   same lines collapse into one finding tagged with both lenses.
10. **Record coverage and the human focus.** State which files you read in full,
    skimmed and did not review, with reasons. Name two or three places where
    human judgement is needed (whether the check proves what the story wants,
    spec fit, what only the CDP Portal run can show), giving priority to anything
    you skimmed or could not verify.

## Report format

Use exactly this structure; findings are numbered one-liners with file/line
references. No praise section, no extra prose.

```
### PR <number>: <title>
Author: <login>  •  <base> → <head>  •  <files> files (+<adds>/−<dels>, <n> generated)  •  CI: <passing/failing>
Spec: <REGEN-NNN and specs/NNNN-… file | "no Jira story — <reason>" | "no Jira story key — flagged">
Size: <within budget | over budget: <n> non-generated lines — suggest splitting at <boundary>>
Reviewed: <n> of <m> files in full  (skimmed: <files — reason>; not reviewed: <package-lock.json>)
Lenses: <applied>  (scoped out: <lens — reason>)

### Acceptance criteria
| Criterion (from the spec or story) | Evidence in this PR                     | Status                                       |
| ---------------------------------- | --------------------------------------- | -------------------------------------------- |
| <AC or edge case as written>       | <test title, or step N of How to test>  | met / not met / not verifiable from the diff |

### Blocking (in spec)
1. <file>:<line> [<lens>] [confirmed — <how: gate run, suite run, request made>] <What is wrong and what fixing it looks like — one or two sentences.>
2. <file>:<line> [<lens>] [from reading] <…>

### Non-blocking (in spec)
1. <file>:<line> [<lens>] <One sentence.>

### Suggested new stories (out of scope for this PR)
1. <Draft story title>
   <Why it's valuable, where the issue lives. Not a request against this PR.>
   Impact if not addressed: <concrete consequence — risk, cost, or missed benefit.>

### Verdict
<"Looks mergeable pending human review — no blocking findings." or
"<N> blocking finding(s) to resolve." — never an approval; a human must review and approve.>
Human review focus: <two or three places where judgement is needed — what the check proves, spec fit, the CDP Portal run>
```

Omit the "Acceptance criteria" section for docs-only and tiny PRs, and say so in
the `Spec:` line.

## Anti-patterns

- Approving, requesting changes, commenting, or reacting on GitHub. The human
  does that, using your report.
- Requesting out-of-scope work in the PR instead of drafting a story for it.
- Applying a standard to lines the PR never touched and calling it blocking.
- Labelling a finding `confirmed` without having reproduced it, or claiming full
  coverage of files you skimmed.
- Reading a green pull request check as proof that the suite passes.
- Padding the report with nits or praise to look thorough.
- Trusting the PR description over the diff, or vice versa, without comparing.
- Leaving a checked-out branch, worktree, stash or report server behind after
  the review.
