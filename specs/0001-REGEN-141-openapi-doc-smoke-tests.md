# 0001 – REGEN-141 – Add post-deployment smoke tests for the v1 and v2 API docs

| Field    | Value                                                                                         |
| -------- | --------------------------------------------------------------------------------------------- |
| Ticket   | [REGEN-141](https://eaflood.atlassian.net/browse/REGEN-141?focusedCommentId=944104) (comment) |
| Type     | Task                                                                                          |
| Priority | P1 (High)                                                                                     |
| Risk     | Low                                                                                           |
| Status   | In progress                                                                                   |
| Date     | 11 November 2026                                                                              |

## Problem/Opportunity

After the Create Organisation / API versioning change (REGEN-141, REGEN-167) was deployed to DEV, the v2 API
documentation could not be viewed anonymously, while v1 still could:

| URL (DEV)                                                                          | Result at the time |
| ---------------------------------------------------------------------------------- | ------------------ |
| `https://waste-organisations.api.dev.cdp-int.defra.cloud/openapi/v1.json`          | Worked             |
| `https://waste-organisations.api.dev.cdp-int.defra.cloud/redoc/index.html?spec=v1` | Worked             |
| `https://waste-organisations.api.dev.cdp-int.defra.cloud/openapi/v2.json`          | Did not work       |
| `https://waste-organisations.api.dev.cdp-int.defra.cloud/redoc/index.html?spec=v2` | Did not work       |

**Root cause:** the API gateway only had an unauthenticated route for `/openapi/v1.json`. The new
`/openapi/v2.json` fell through to the Cognito-protected `/{proxy+}` route and returned `401` before reaching the
service. The ReDoc page for v2 itself loaded but could not fetch its document.

**Fix:** [DEFRA/cdp-tenant-config#2139](https://github.com/DEFRA/cdp-tenant-config/pull/2139), merged 11 November
2026, adds an unauthenticated `GET /openapi/v2.json` route in dev, test, perf-test and prod. All four URLs are
expected to return `200` today.

Nothing detected this after deployment; it was found by a person opening the page. The team has no automated check
that a deployed `waste-organisations` service is in a working state.

The opportunity is to introduce simple post-deployment smoke tests, starting with the API docs. The tests do not
validate functionality; they only confirm the service is up and serving its documentation to anonymous callers.

**Who benefits:** the delivery team (a broken deployment is caught in minutes, not days) and consuming W&CE teams
who rely on the published API docs.

**Why P1:** a defect reached DEV undetected while REGEN-141 is still in progress. It is fixed now, but nothing
would catch a regression or a similar gateway misconfiguration for a future API version.

## Proposed Solution

Add four HTTP smoke tests to this repository, run from the CDP Portal against the public API host of the selected
environment.

| #   | Request                         | Credentials | Expected |
| --- | ------------------------------- | ----------- | -------- |
| 1   | `GET /openapi/v1.json`          | None        | `200`    |
| 2   | `GET /openapi/v2.json`          | None        | `200`    |
| 3   | `GET /redoc/index.html?spec=v1` | None        | `200`    |
| 4   | `GET /redoc/index.html?spec=v2` | None        | `200`    |

- **Target host:** `https://waste-organisations.api.${ENVIRONMENT}.cdp-int.defra.cloud` – the public API host from
  the bug report, so the tests go through the API gateway as an anonymous consumer does. This is a firm decision:
  the bug was a gateway `401`, which the internal service host would not have reproduced.
- **Any environment:** the host is derived from the `ENVIRONMENT` variable supplied by CDP, so the same image runs
  unchanged in every environment. An optional override variable, `SERVICE_BASE_URL`, allows a run against a
  local instance. When it is set, it is used as the base URL in full and `ENVIRONMENT` is ignored.
  When neither variable is set, the suite fails before any request is made, with an error that names both
  variables, instead of calling an `undefined` host.
- **Trigger:** the suite is started manually from the CDP Portal (Test Suites). See Notes for automation.
- **Anonymous:** no `Authorization` header, API key or cookies are sent.
- **No redirects followed:** a redirect (for example to a login page) fails the test instead of passing as a `200`.
- **One test case per URL**, so the report shows exactly which document or page failed. A failure message includes
  the URL requested and the status received.
- **Plain HTTP, no browser:** the tests use Node's built-in `fetch` (Node 24) inside the existing WDIO/Mocha
  runner. No new dependency. Allure reporting, the `FAILED` file written in `onComplete`, `entrypoint.sh` and
  `bin/publish-tests.sh` stay as they are, so the suite keeps meeting the CDP Portal contract.
- **Proxy:** outbound calls from CDP go through `HTTP_PROXY`. Node's `fetch` only honours it when
  `NODE_USE_ENV_PROXY=1` is set, so the `test` script must set it. The variable must prefix the `wdio run`
  command itself, not the preceding `npm run clean`, otherwise it never reaches the test process.
- **Failure semantics:** each request uses `redirect: 'manual'` and a 30 second `AbortSignal.timeout`. A `3xx`
  status, a non-`200` status, a timeout and a network error all fail the test with a message that names the URL.
  Assertions use `node:assert/strict` so the message is under the test's control.
- **Extensible:** the doc versions are held in one list, so adding v3 is a one-line change.
- **Placeholder removed:** the CDP template's home-page test (`test/specs/home.e2e.js`) and its page objects
  (`test/page-objects/home.page.js`, `test/page-objects/page.js`) are deleted. The test opens a placeholder
  `baseUrl` that does not exist, so leaving it in would fail every run.
- **README:** updated to say what the suite checks, which host it targets and how to run it.

Location: `test/specs/api-docs.smoke.js` (matched by the existing `./test/specs/**/*.js` glob in
`wdio.conf.js`).

- **Local run:** `wdio.local.conf.js` only matches `./test/specs/**/*.e2e.js`, so its `specs` glob is widened to
  `./test/specs/**/*.js` to match `wdio.conf.js`. A local run is `SERVICE_BASE_URL=<url> npm run test:local`; the
  `test` script needs a remote chromedriver and is for CDP. No other WDIO config changes.

## Acceptance Criteria

- [ ] `GET /openapi/v1.json` with no credentials returns `200` and its test passes.
- [ ] `GET /openapi/v2.json` with no credentials returns `200` and its test passes.
- [ ] `GET /redoc/index.html?spec=v1` with no credentials returns `200` and its test passes.
- [ ] `GET /redoc/index.html?spec=v2` with no credentials returns `200` and its test passes.
- [ ] Run against DEV from the CDP Portal, all four tests pass and the suite exits `0`.
- [ ] The same image runs against any CDP environment using only `ENVIRONMENT`; no environment URL is hard-coded.
- [ ] The placeholder home-page test and its page objects no longer exist, and the suite runs only the four doc
      tests.
- [ ] The README describes what the suite checks and how to run it.
- [ ] `npm run lint` and `npm run format:check` pass.

### Edge cases

- A `3xx` response is a failure, not a pass.
- A network error or timeout is a failure and reports the URL.
- A ReDoc page returning `200` does not on its own prove the v2 document loads, because the page fetches the JSON
  client-side. That is why the JSON documents are checked directly as well; the tests do not render the page.

## Out of Scope

- The v2 doc bug itself, which has already been fixed on the API gateway.
- Functional or contract testing of the API (payloads, validation, auth rules, versioning behaviour).
- Validating the content of the OpenAPI documents or the rendered ReDoc page.
- Running the suite automatically after each deployment; a manual run from the CDP Portal is enough.
- Changing the template's GitHub workflow (`journey-tests.yml`, `run-journey-tests/`, `compose.yml`). It is kept
  as it is and is not required to run these tests.
- Other template clean-up beyond the placeholder test and its page objects (for example the BrowserStack configs).
- Further smoke checks such as `/health` or an unauthenticated `GET /organisations` returning `401`.

## Notes

### Risks and uncertainties

- **Reachability of the public API host from CDP.** Not yet confirmed that a CDP test suite can call
  `waste-organisations.api.<env>…` through the platform proxy. The public host is required (the internal host
  bypasses the gateway), so if it is unreachable the fix is a platform change, such as a proxy allow-list entry,
  not a change of host. This can only be checked after merge, because the test image is built on merge to `main`,
  so it is checked on the first CDP Portal run.
- **Proxy setting applies to the whole WDIO process.** `NODE_USE_ENV_PROXY=1` is set on the `wdio run` command, so
  it covers WebdriverIO's own connection to chromedriver as well as the tests' `fetch` calls. Watch the first CDP
  Portal run for chromedriver connection errors. If they appear, the chromedriver host needs to be excluded from
  the proxy with `NO_PROXY`.
- **Environments.** The suite is generic, but it asserts that the docs are anonymously viewable. Per the fix PR,
  ext-test has no documentation routes on the gateway, so the suite is expected to fail there; dev, test, perf-test
  and prod have them.
- **Each new API version needs its own gateway route.** Anonymous access is granted per document in
  `cdp-tenant-config`, so a future `/openapi/v3.json` will return `401` until a route is added. Adding v3 to the
  test list is what would catch that.
- **Browser session.** The WDIO runner still starts a Chrome session even though the tests do not use it, and
  `afterTest` takes a screenshot on failure. Harmless, but the screenshot is of a blank page.

### Running and automating on CDP

- A manual run needs the suite to be registered in the CDP Portal as a test suite and its image published; the
  existing `.github/workflows/publish.yml` builds and publishes the image on merge to `main`.
- Triggering a run automatically after a `waste-organisations` deployment is a CDP Portal setting, not something
  this repository can configure. To be confirmed against the CDP documentation if automation is wanted later.
- The repository's own GitHub workflow cannot stand in for it: per the README, GitHub runners cannot connect to
  the CDP environments.

### Next steps

1. After merge, run the suite against DEV from the CDP Portal. This confirms the public API host is reachable from
   a CDP test suite run and that all four tests pass.
2. On that first run, watch for chromedriver connection errors caused by the proxy setting.
