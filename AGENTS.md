# waste-organisations-smoke-tests

Post-deployment smoke tests for the `waste-organisations` API, run from the CDP Portal as a test suite against the public API host of the selected environment. The repository is the test suite: it has no production code. All work in this repo must follow the [DEFRA software development standards](https://github.com/DEFRA/software-development-standards).

## Detailed standards

The rules below are the always-applicable summary. The full standards, tailored to this repo, live in `doc/rules/`. **Read the relevant file before starting the matching kind of task**:

- [javascript-nodejs.md](doc/rules/javascript-nodejs.md): writing any JavaScript; spec files, the WebdriverIO and Mocha runner; adding npm packages
- [common-coding.md](doc/rules/common-coding.md): readability, naming, comments, simplicity
- [git-workflow.md](doc/rules/git-workflow.md): branches, commit messages, PR titles, the full PR process
- [security-logging.md](doc/rules/security-logging.md): secure coding, credentials, what a failure message and a report may contain
- [quality-assurance.md](doc/rules/quality-assurance.md): what a smoke check is, acceptance criteria, what "verified" means here
- [continuous-integration.md](doc/rules/continuous-integration.md): workflow changes, action pinning, the CDP Portal contract
- [containers.md](doc/rules/containers.md): Dockerfile, `entrypoint.sh` and `compose.yml` changes

## Reusable skills

Agent-invocable procedures live in `.agents/skills/` in the open Agent Skills format (`SKILL.md`). Codex reads that directory natively; Claude Code reads the same skills through the `.claude/skills/` symlinks. When a task matches one of these skills, follow the skill rather than improvising:

- `spec-clarify`: turn a Jira story, bug or idea into a spec in `specs/`, in the repo's format, by asking the author questions; the first step of every story.
- `commit`: stage and commit finished work as atomic commits with Conventional Commits messages.
- `pr-review`: review a colleague's PR against the linked Jira story and these standards. Findings are reported for a human to act on; the AI never approves, requests changes, or comments.
- `pr-preflight`: pre-flight check of your own PR before requesting human review; may fix mechanical, in-spec blocking findings (new commit, plain push, gate first).

Both review skills enforce scope discipline: AI-suggested changes must be in spec (the linked story's acceptance criteria plus these standards on the lines the PR touches). Valuable out-of-scope findings are raised as suggested new Jira stories, never as changes or change requests on the PR.

## Language and framework

- Vanilla JavaScript on Node.js, as ES modules (`"type": "module"`). No TypeScript, no type annotations, no `.ts` files.
- The runner is WebdriverIO with the Mocha framework (`describe` and `it`), reporting to Allure. Spec files live under `test/specs/`.
- A check that needs only an HTTP response uses Node's built-in `fetch` and `node:assert/strict`. Do not add an HTTP client or an assertion library for it, and do not drive the browser when a request proves the same thing.
- `async`/`await` throughout. No fixed sleeps (`browser.pause`, `setTimeout`): a request carries its own timeout, a browser step waits on a condition.
- The target host comes from `ENVIRONMENT` or `SERVICE_BASE_URL` (README, "Target host"). Never hard-code an environment's URL in a spec file.

## Code style

- Linting is ESLint (`eslint.config.js`) and formatting is Prettier; do not hand-format and do not relax either configuration to get a check green. Conventions are in `.editorconfig` and `.prettierrc.js`.
- `console` calls are lint errors. What a check has to say goes in its test title and its assertion message.
- Intent-revealing names; no generic names (`temp`, `data2`, `x`); spell out a domain acronym (CDP, EPR) where it is first used. Prefer small, named functions over comments; comments explain _why_, never _how_. Never leave commented-out code. No `TODO` without a Jira reference.
- Simplicity first: no speculative abstraction or premature reuse. Apply the rule of three before extracting shared code.

## Dependencies

- npm only, with exact versions in `package.json`. The `.npmrc` settings (`save-exact`, `ignore-scripts`, `min-release-age`) must not be weakened.
- Vet a new package before adding it (maintained, widely used, OGL-compatible licence, security history) and say why it was chosen in the PR.
- A package the suite needs to run on CDP is a `dependency`; lint and format tooling is a `devDependency`.
- The Node version is the one in `.nvmrc`, and the `FROM` line of the `Dockerfile` carries the same version: change them together.

## The gate and what "verified" means

- **The gate** is `npm run format:check` then `npm run lint`. The pre-commit hook and the `Run Pull Request Checks` workflow run exactly this, and nothing else.
- The gate does not run the suite. A change to a check, to a `wdio.*.conf.js` file, to `package.json` or to `entrypoint.sh` is **verified** only when the suite has also been run against a running `waste-organisations` with `SERVICE_BASE_URL` and every test passed (commands below).
- A new or changed check is also seen to fail: run it where its condition does not hold and confirm that the suite fails and the message names the URL requested.
- The run from the CDP Portal can only happen after merge, because the image is built on merge to `main`. Say in the PR what that first run still has to confirm.
- Never weaken, delete or skip a check or an assertion to make a run pass. A failing check is reporting something about the environment; understand it first.

## Smoke checks

- A check is defined by four things, written in its spec and in the README table "What the suite checks": the request, the credentials sent, the expected result, and what counts as a failure. Change the README table in the same PR as the check.
- One test case per URL, so the report shows which one failed. The failure message names the URL requested and the status received.
- Redirects are not followed: a `3xx` is a failure. Any status other than the expected one, a network error and a timeout are failures.
- Checks go to the public API host, through the API gateway, as a consumer does.
- Negative cases are the conditions that must fail the suite; they matter as much as the passing ones.

## Security

- Follow the OWASP Secure Coding Practices quick reference guide (version 2).
- This repository is public. Never commit a credential, token or connection string. A check that needs credentials reads them from environment variables supplied as CDP secrets. If a secret ever reaches git history, treat it as compromised and follow Defra's credential exposure process.
- A failure message, a test title and the Allure report never carry a credential, an `Authorization` header, a response body or personal data. Test data is synthetic.
- In GitHub Actions, a new or changed `uses:` line pins the action to a full commit SHA with the version as a trailing comment, never a tag or branch.

## Git workflow

- All work happens on a branch named `REGEN-NNN-short-slug` (work with no Jira story takes a short descriptive name and no key); never commit directly to `main`. Main is always shippable.
- Branch commits follow Conventional Commits (`type(scope): subject`, imperative, at most 50 characters, optional body of up to three bullets), made with the `commit` skill, with no tool signatures or co-author trailers.
- PRs are small and focused on one change, titled `REGEN-NNN: summary` (no prefix when the work has no Jira story), described with `.github/PULL_REQUEST_TEMPLATE.md` including its "How to test" section, squash-merged with the PR title and description as the commit message, and the branch deleted after merge (see "Commits And Pull Requests" below).
- A human developer reviews and approves every PR. AI review supplements that review and never approves.

## AI-assisted development

- Read this file and the matching `doc/rules/` file before changing anything. If a request conflicts with these rules, say so and stop; never proceed silently or work around a rule.
- Ralph loop: one plan item per iteration. Never stage or commit `IMPLEMENTATION_PLAN.md`, `PROGRESS.md`, `PROMPT_*.md`, `ralph.yaml` or `.ralph/`. Stop and report, instead of forcing a fix, when a check fails against a service that should pass it, when a delivered spec would need editing, or when an acceptance criterion cannot be met without a decision.
- Never put secrets, credentials or personal data into prompts, specs, tickets or test data.
- Reference files, specs and standards by path or link; do not paste them into prompts or rules.
- Do not report a change as verified on the strength of the gate alone when "verified" above asks for a suite run. If no running `waste-organisations` is available, say that the suite was not run.

## Local Commands

Run these from the repository root.

Use the Node version in `.nvmrc` (`nvm install` first if that version is not installed):

```bash
nvm use
```

Install dependencies exactly as the pull request check does:

```bash
npm ci
```

`.npmrc` sets `ignore-scripts=true`, so the install does not set up the Git hooks. Set them up once per clone, so the pre-commit hook runs the gate:

```bash
npm run setup:husky
```

The gate:

```bash
npm run format:check
```

```bash
npm run lint
```

Fix what the gate reports instead of editing by hand:

```bash
npm run format
```

```bash
npm run lint:fix
```

Run the suite against a running `waste-organisations`. `<url>` is the base URL of that service, for example `http://localhost:8080` when it runs locally on port 8080; start the service as its own repository describes. WebdriverIO starts a local Chrome for the run and downloads a driver the first time:

```bash
SERVICE_BASE_URL=<url> npm run test:local
```

The command exits `0` when every test passes and `1` when one fails. With neither `SERVICE_BASE_URL` nor `ENVIRONMENT` set it fails before any request is sent. After the tests, the local configuration generates the Allure report (this needs Java) and leaves a report server running after the command returns: stop that process when you have read the report.

`npm test` is the command `entrypoint.sh` runs on CDP: it expects a remote chromedriver and the platform's environment variables, so it is not the local command.

## Specs

Specs live in `specs/` and are named `NNNN-TICKET-ID-slug.md`. A spec whose development is done (its story is delivered and the changes are merged) is a record of what was built and why. Never edit such a spec, not even its Notes, while doing new development or writing a new spec. When new work changes something an earlier spec decided, such as a check it introduced or a failure rule, record the change and its reason in the new spec, name the earlier spec it supersedes and in what, and leave the earlier spec as it is. Edit a spec only while its own story is still in progress; the `Status` row of its metadata table says which it is.

A new spec is written with the `spec-clarify` skill, so it has the sections and the positive and negative acceptance criteria the team expects. A spec whose work would exceed the pull request size guide in `doc/rules/git-workflow.md`, or that mixes a runner or tooling change with new checks, is split into smaller specs before development starts, one pull request each. Each skill has a README for developers in its folder under `.agents/skills/`.

## Commits And Pull Requests

Branches are named after the Jira story: the key followed by a short slug, for example `REGEN-141-openapi-doc-smoke-tests`. Older branches use `feature/REGEN-141-...`; the story number is the `REGEN-NNN` part either way. Work that is not associated with a Jira story takes no key: the branch has a short descriptive name and the PR title is the summary alone. Never invent a placeholder key.

Start every pull request title with the Jira story number, a colon and a short summary, for example `REGEN-141: Add smoke tests for the v1 and v2 API docs`. Take the story number from the branch name; if the branch has none, ask rather than guess. Work with no Jira story takes no prefix. The description follows `.github/PULL_REQUEST_TEMPLATE.md`; its "How to test" section is required for any change to a check, the runner, the image or configuration, so QA or another developer can verify the change without reading the code.

Commits on a branch keep their Conventional Commits subjects (`test(smoke): ...`); the `commit` skill produces them. The squash commit is what `main` records: its subject is the pull request title and its body is the pull request description, never the list of branch commit messages. Merge with "Squash and merge". See `doc/rules/git-workflow.md` for the full process.
