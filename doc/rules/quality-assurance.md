# Quality assurance and test standards

Adapted for this repo from the DEFRA [quality assurance and test standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/quality_assurance_standards.md).

This repository is the test suite for a deployed service. It has no user interface and no production code, so the DEFRA criteria about screens, the GOV.UK Design System, browsers, WCAG and unit test coverage do not apply here. The rules for a smoke check below come from `specs/0001-REGEN-141-openapi-doc-smoke-tests.md` and the README ("What the suite checks", "Target host"); a later spec that changes one of them says so and names the spec it supersedes.

## What a smoke check is

- A smoke check confirms that a deployed `waste-organisations` is up and serving something to the caller it is meant to serve. It does not test functionality, payloads, validation or the content of a document; that is the job of the tests in the `waste-organisations` repository.
- A check goes to the public API host of the environment, through the API gateway, as a consumer does. The internal service host bypasses the gateway and would hide a gateway fault.
- The same image runs in every environment. The host is derived from `ENVIRONMENT`, or taken in full from `SERVICE_BASE_URL` when that is set; no environment URL is hard-coded.

## Defining a check

Every check is defined in its spec, and listed in the README table "What the suite checks", by:

| Part            | Rule                                                                                                                                 |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Request         | The method and the path, including the query string.                                                                                 |
| Credentials     | What is sent. "None" means no `Authorization` header, no API key and no cookie. Any credential is named by its environment variable. |
| Expected        | The one status that passes.                                                                                                          |
| Failure         | Everything else: a `3xx` (redirects are not followed), any other status, a network error, and a timeout of 30 seconds.               |
| Failure message | Names the URL requested and the status received, or the network error, so the report alone says what broke and where.                |

- One test case per URL, so the report shows which one failed. Do not fold several URLs into one test or stop at the first failure.
- The test title states the request and the expected result, for example `GET /openapi/v1.json returns 200 without credentials`.
- Assertions carry their own message. An assertion that fails with only "expected 200, got 401" and no URL is not finished.
- With neither `ENVIRONMENT` nor `SERVICE_BASE_URL` set, the suite fails before it sends any request, with an error that names both variables.
- No arbitrary waits. A request has a timeout; nothing sleeps for a fixed time in the hope that the service is ready.
- Each test is independent and passes in any order. A check never depends on data another check or another run created.

## Acceptance criteria

- Every story has positive **and** negative acceptance criteria written in its spec before development starts.
- An acceptance criterion is a check against a deployed environment: a request, the credentials, and the result that passes, plus the criteria for running it (which environments, from the CDP Portal, exit code `0`).
- **Negative cases are the conditions that must fail the suite**, and they are as important as the passing ones. "The v2 document returns `200` to an anonymous caller" implies "a `401` from the gateway fails the test", "a redirect to a login page fails the test" and "an unreachable host fails the test and names the URL". Write them down, and see each one fail before calling the check done.
- An environment where a check is expected to fail is recorded in the spec with the reason. It is never handled by skipping the test or by a condition in the code.

## Verified

A change is verified by what the repository really runs, in this order:

1. **The gate**: `npm run format:check` and `npm run lint` pass. This is what the pre-commit hook and `.github/workflows/check-pull-request.yml` run. It proves style and nothing about behaviour.
2. **The suite run**: for a change to a check, a `wdio.*.conf.js` file, `package.json` or `entrypoint.sh`, the suite is run against a running `waste-organisations` with `SERVICE_BASE_URL` and every test passes (command in "Local Commands" in `AGENTS.md`).
3. **The failing run**: a new or changed check is run where its condition does not hold, and the suite fails with a message that names the URL.
4. **The CDP Portal run**: the image is built on merge to `main`, so the run from the CDP Portal against a real environment happens after merge. The PR's "How to test" section says what that run still has to confirm, and the story is not done until it has.

Do not describe a change as verified by a step that was not run. If no running `waste-organisations` was available, the PR says the suite was not run.

- Never weaken, delete or skip a check or an assertion to make a run pass. A red check is reporting something about the environment; understand it first.
- No skipped test (`it.skip`, `describe.skip`, `xit`) is committed without a Jira reference in its title or a comment beside it.

## Wider QA practice

- Stories that change what the suite checks are tried against a real CDP environment after merge, not only against a local service.
- Keep the team aware of testing risks: a check that cannot run in an environment, or a fault class the suite cannot see, is written in the spec's Notes.
