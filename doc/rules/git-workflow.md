# Git workflow: version control, commits and pull requests

Adapted for this repo from the DEFRA [version control standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/version_control_standards.md), [pull requests process](https://github.com/DEFRA/software-development-standards/blob/main/docs/processes/pull_requests.md) and [developer workflows guide](https://github.com/DEFRA/software-development-standards/blob/main/docs/guides/developer_workflows.md).

## Version control standards

- All code is held in the Defra GitHub organisation (`DEFRA/waste-organisations-smoke-tests`).
- GitHub flow: `main` plus short-lived story branches. CDP supports no other workflow.
- `main` is protected by a repository ruleset: one approving review, dismissed when new commits are pushed; the `Run Pull Request Checks` status check on a branch that is up to date with `main`; resolved review threads; signed commits; no force pushes or deletion.
- Every merge to `main` builds and publishes the test suite image through the CDP build action (`.github/workflows/publish.yml`). **Accepted deviation:** the DEFRA standard asks for a version number in the source code; here CDP owns the version of the image it builds, as it does for every suite and service it hosts, and `package.json` carries no release version.

## Pull request process

Goals: focused PRs, simple reviews, a clean commit history, and respect for reviewers' time.

1. **Always on a branch.** However small the change: `git switch -c REGEN-NNN-short-slug`, for example `REGEN-141-openapi-doc-smoke-tests`. The DEFRA process uses a plain descriptive name; this repo prefixes the Jira key so the PR title and story can be derived from it. Older `feature/REGEN-NNN-...` branches exist; new branches use the new form. Work that is not associated with a Jira story takes no key: the branch has a short descriptive name and the PR title is the summary alone. Never invent a placeholder key.
2. **Start with an empty commit** (`git commit --allow-empty`) using this template, so the PR is visible from the start:

   ```text
   50 character limited title

   Jira story key

   Description covering why we're making this change, and briefly what the change is.
   ```

   Cover **the actual change you intend to make**, not a repeat of the backlog story; the Jira story key provides that context.

3. **Push immediately and open the PR** (`git push -u origin REGEN-NNN-short-slug`). Title it `REGEN-NNN: summary`, or the summary alone when the work has no Jira story, and fill in `.github/PULL_REQUEST_TEMPLATE.md`, which GitHub offers in place of the commit message; the empty commit still carries the why in the history. Assign yourself. Open it as a draft until it is ready for review, and complete the "How to test" section before you request review.
4. **Code, committing frequently** with the `commit` skill: Conventional Commits subjects and short bulleted bodies (see "Commit messages" below). Keep `WIP` noise to a minimum; the messages are visible in the PR. Commits must be signed, or the ruleset blocks the merge.
5. **Keep your branch up to date** with `git rebase origin/main` (preferred over merge, to keep the PR history clean). The required check only counts on a branch that is up to date with `main`. Never rebase or force-push a branch someone else is working on.
6. **Keep the PR small.** One spec slice or one plan item per PR. A PR that mixes a runner change, a new check and a refactor is three PRs. Size guide: at most about 800 non-generated changed lines (generated means `package-lock.json`); above that, split by spec slice before asking for review. The `pr-review` and `pr-preflight` skills flag a PR over the guide with a suggested split point. The team can revise the figure here.
7. **Get it reviewed.** At least one other developer must review and approve before merge. AI review (the `pr-preflight` and `pr-review` skills) prepares for the human review and never replaces or approves it.
8. **Squash and merge**, then **delete the branch**. The squash commit is what `main` records: its subject is the PR title and its body is the PR description, never the list of every branch commit message. Choose "Squash and merge", not "Create a merge commit": a merge commit would put the branch commits on `main`.

## Pull request description

The description follows `.github/PULL_REQUEST_TEMPLATE.md`:

- **Why**: why the change is needed and briefly what it does, with the Jira story key, or `Jira: none` with the reason when the work has no story, and the spec file. Not a copy of the story.
- **What changed**: one bullet per change in what the suite checks or how it runs, not per file.
- **How to test**: everything QA or another developer needs to verify the change without reading the code: the service the suite was run against and its base URL, the command, the expected result for each check, the conditions that must fail the suite and how each was seen to fail, and what only a run from the CDP Portal can confirm. Required for any change to a check, the runner, the image or configuration; "No behaviour change: <reason>" is acceptable for a docs-only or tooling PR.
- **Checklist**: the gate, the suite run, the README table, no credentials or personal data, new dependencies.

This is how the repo meets the DEFRA quality assurance standard's expectation that each story's testing is documented alongside the story. The `pr-review` and `pr-preflight` skills check that "How to test" is present, matches the diff and could be followed without reading the code.

## Commit messages

**Branch commits** follow [Conventional Commits](https://www.conventionalcommits.org/): `<type>(<scope>): <subject>` with an imperative subject of at most 50 characters and an optional body of at most three short bullets. The `commit` skill in `.agents/skills/commit` produces this format. Branch commits carry no Jira key, and the DEFRA process asks only that interim messages are not ignored. No tool signatures or co-author trailers.

**The PR title and the squash commit** are what `main` records, so the DEFRA commit message rules apply to them, and to the empty commit that opens the PR:

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalise the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line (_Add ability_, not _Added ability_)
6. Use the body to explain _what and why_, not _how_, and name the Jira story key

Source: [How to write a Git commit message](https://chris.beams.io/posts/git-commit/), as adopted by the DEFRA pull requests process.

## Ralph loop commits

- The build loop commits with the `commit` skill after the gate passes and, where "Verified" in [quality-assurance.md](quality-assurance.md) asks for it, after the suite run, one plan item per commit or per small set of atomic commits.
- Loop artefacts (`IMPLEMENTATION_PLAN.md`, `PROGRESS.md`, `PROMPT_*.md`, `ralph.yaml`, `.ralph/`) are gitignored and never staged.
- Merging to `main` is always a human's squash merge after review; the loop pushes to the story branch only.
