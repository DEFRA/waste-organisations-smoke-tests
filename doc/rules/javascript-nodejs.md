# JavaScript and Node.js standards

Adapted for this repo, a WebdriverIO and Mocha test suite, from the DEFRA [JavaScript standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/javascript_standards.md) and [Node.js standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/node_standards.md). The DEFRA rules for web servers and browser code (server framework, session state, front-end frameworks, progressive enhancement) have nothing to apply to here.

## JavaScript

- Use vanilla JavaScript. Do not use extensions to the language such as TypeScript without an approved exception: no `.ts` files, no type annotations, no JSDoc-driven type checking introduced as a workaround.
- Use ES modules (this package is `"type": "module"`). CommonJS only where a dependency genuinely requires it.
- Prefer `async`/`await` over callbacks and promise chains. Every promise in a test is awaited or returned; a floating promise lets a test pass before its assertion has run.
- **Accepted deviation:** the DEFRA standard lints with neostandard. This repo keeps the ESLint flat configuration of the CDP journey test suite template (`eslint.config.js`: the ESLint recommended rules, `eslint-plugin-wdio` and Prettier), for consistency with the other CDP test suites. Do not change the linter or the Prettier configuration without a team decision, and do not disable a rule inline without a comment that says why.

## Node.js

- The Node version is the one in `.nvmrc`. When it changes, it moves to an Active LTS version: never behind Maintenance LTS, never beyond Active LTS.
- Prefer what Node provides to a dependency: `fetch` for HTTP, `AbortSignal.timeout` for a request timeout, `node:assert/strict` for assertions.

### Package management

- Use npm only. Any other package manager requires governance approval.
- Pin all dependencies to exact versions in `package.json`: never `^`, `~`, `*`, `x` or ranges. Commit `package-lock.json` with every dependency change.
- A package the suite needs to run in the image is a `dependency`; a package used only to lint or format is a `devDependency`.
- Use `npm ci`, not `npm install`, in CI and for a local install that must match the lock file.
- Vet third-party packages before adding them: see the DEFRA [choosing packages guide](https://github.com/DEFRA/software-development-standards/blob/main/docs/guides/choosing_packages.md) and "Dependencies" in `AGENTS.md`.
- The repo `.npmrc` must keep these settings:

  | Setting               | Purpose                                                                                                                                                                                                                                |
  | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | `save-exact=true`     | Saves exact versions; prevents version-range drift pulling in a later, potentially vulnerable release.                                                                                                                                 |
  | `ignore-scripts=true` | Blocks `preinstall`/`postinstall` lifecycle scripts, a common vector for arbitrary code execution from compromised packages. Pass `--ignore-scripts=false` per command only when a package genuinely needs it.                         |
  | `min-release-age=7`   | Refuses packages published fewer than 7 days ago, giving time for package-takeover and typosquatting attacks to be detected. Bypass a single install with `--min-release-age=0` only after due diligence on the package and publisher. |

## The test suite

### Layout

- Spec files live under `test/specs/`. Every WebdriverIO configuration picks them up with the same glob, so a file placed there runs everywhere; do not narrow the glob in one configuration only.
- One spec file per area of the service being checked, named for that area.
- `wdio.conf.js` is the configuration CDP runs, through `npm test`. `wdio.local.conf.js` is for a developer's machine. A setting that changes what a check does or how it fails is the same in both.

### Mocha

- Use the BDD interface: `describe` for the area, one `it` per check. `describe`, `it` and the hooks are globals; do not import them.
- A test title states the request and the expected result. It is what the report shows, so it must be understood without the code.
- No `it.only` or `describe.only` is committed.
- A list of similar checks is generated from one list of values (the document versions, for example), so adding a case is a one-line change and every case gets its own `it`.
- Module-level code in a spec file only reads configuration and fails fast when it is missing. Requests happen inside `it`.
- Keep a check well inside the Mocha timeout set in the configuration: a request's own timeout is shorter, so a slow service fails with a message that names the URL, not with a bare Mocha timeout.

### HTTP checks

- Use Node's built-in `fetch` with `redirect: 'manual'` and an `AbortSignal.timeout`. Do not add an HTTP client.
- Catch a rejected `fetch` and rethrow with the URL in the message and the original error as `cause`.
- Assert with `node:assert/strict` and pass the message yourself, including the URL and the status received.
- Build the URL from the base URL and the path in one place, and use that same value for the request and for the message.

### Browser checks

The current checks do not use the browser, although the runner starts a session. A check drives the browser only when what it proves cannot be seen in an HTTP response.

- Use the WebdriverIO globals (`browser`, `$`, `$$`, `expect`) that the runner provides.
- Wait on a condition (`waitForDisplayed`, `waitUntil`, an `expect` matcher that retries), never on time: no `browser.pause` and no `setTimeout`.
- `browser.debug()` is never committed.
- Select elements by a stable attribute or role, not by layout or generated class names.
