# Continuous integration standards

Adapted for this repo from the DEFRA [continuous integration standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/continuous_integration.md).

## What CI checks

The workflows are the source of truth; read them rather than rely on a list here. What matters when changing them:

- `.github/workflows/check-pull-request.yml` is the pull request check. Its `Run Pull Request Checks` job runs the gate: the format check and the lint. Its `Run Journey Tests` job calls `.github/workflows/journey-tests.yml`, which starts the latest published `waste-organisations` image with `compose.yml` and runs the suite against it. GitHub runners cannot reach the CDP environments and that stack has no API gateway, so a green check does not show that the checks pass on CDP (see "Verified" in [quality-assurance.md](quality-assurance.md)).
- `.github/workflows/publish.yml` builds and publishes the test suite image on every merge to `main` through Defra's `cdp-build-action`. The CDP Portal runs that image. Do not replace it with a bespoke build.
- `.github/workflows/journey-tests.yml`, `run-journey-tests/action.yml`, `compose.yml` and `bin/start-stack.sh` are how the suite runs on a GitHub runner and, with `npm run stack:up`, on a developer's machine. They began as the CDP journey test suite template's files and now start `waste-organisations` with MongoDB and Postgres, the Postgres schema applied by Liquibase from the service's changelog. They are not part of the gate.

The pre-commit hook and the `Run Pull Request Checks` job run the same two commands. A command added to one is added to the other in the same change.

## Branch protection

`main` is protected by a repository ruleset that requires the `Run Pull Request Checks` status check on an up-to-date branch, one approving review, resolved review threads and signed commits (see [git-workflow.md](git-workflow.md)). The required check is the job's `name`. Renaming the job renames the required check: update the ruleset in the same change, or the PR cannot merge.

## GitHub Actions

Use GitHub Actions for CI builds.

### Commit SHA pinning

The DEFRA standard requires every action to be pinned to a full-length commit SHA, never a tag or branch. Tags and branches can be moved by an attacker who compromises the action's repository. A `uses:` line that a change adds or edits follows the standard, with the version as a trailing comment:

```yaml
# Use:
uses: aquasecurity/trivy-action@57a97c7e7821a5776cebc9bb87c984fa69cba8f1 # 0.35.0

# Not:
uses: aquasecurity/trivy-action@v0.35.0
# Nor:
uses: aquasecurity/trivy-action@main
```

To update an action, test the new version, then update the SHA and the comment together. Find the SHA by viewing the commit for the target tag in the action's repository; never write one from memory.

### Permissions

A workflow declares the least `permissions` it needs. Write permissions and `id-token: write` belong to the workflow that publishes, not to the pull request check.

## The CDP Portal contract

The CDP Portal decides whether a run passed from what the container does, as the README describes under "Requirements of CDP Environment Tests". These must keep working through any change:

- `entrypoint.sh` exits `0` when the suite passes and non-zero when it fails or when the report cannot be published.
- The `test` script in `package.json` writes the `FAILED` file when Mocha exits with a failure; `entrypoint.sh` reads it.
- The `allure-mocha` reporter, set in `.mocharc.json`, writes `allure-results/`. The Allure report is generated from it and published to S3 by `bin/publish-tests.sh`.
- Outbound requests on CDP go through the platform proxy. Node's `fetch` honours it only when `NODE_USE_ENV_PROXY=1` is set on the command that runs the tests, not on a command that precedes it.

A change that touches any of these is verified by a run from the CDP Portal after merge, and its PR says so.
