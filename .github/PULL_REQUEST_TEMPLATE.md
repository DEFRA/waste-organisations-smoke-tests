<!-- Title: REGEN-NNN: Short summary (imperative, capitalised, 50 characters, no trailing period). No prefix when the work has no Jira story. See doc/rules/git-workflow.md. -->

## Why

<!-- Why this change is needed and briefly what it does. Not a copy of the story. -->

Jira: REGEN-NNN <!-- or "none" with the reason when the work has no Jira story -->
Spec: specs/NNNN-REGEN-NNN-slug.md <!-- or "none" -->

## What changed

- <!-- One bullet per change in what the suite checks or how it runs, not per file -->

## How to test

<!-- Everything QA or another developer needs to verify this change without reading the code.
     Required for any change to a check, the runner, the image or configuration. For a docs-only
     or tooling PR, replace this section with "No behaviour change: <reason>". -->

**Target:** <!-- The waste-organisations the suite was run against: a local instance and its base URL, and/or the CDP environment -->
**Command:** <!-- For example `SERVICE_BASE_URL=<url> npm run test:local` -->

### Steps

1. <!-- Run the command. Expected: which tests pass, by title, and exit code 0 -->
2. <!-- Condition that must fail the suite (for example the service stopped, a path that returns 401, a redirect) and how to produce it. Expected: which test fails and the message, naming the URL and the status -->

### Not covered

- <!-- What only a run from the CDP Portal after merge can confirm (reachability through the platform proxy, the report in the portal, an environment where the check is expected to fail) -->

## Checklist

- [ ] Gate run locally: `npm run format:check` and `npm run lint`
- [ ] Suite run against a running `waste-organisations` and every test passed, or this PR changes no check, runner, image or configuration
- [ ] Each new or changed check was seen to fail, with a message that names the URL
- [ ] README table "What the suite checks" updated for any new or changed check
- [ ] No credentials, tokens or personal data in code, messages, test data or the spec
- [ ] New dependencies pinned to exact versions, with the reason for choosing them in the description
