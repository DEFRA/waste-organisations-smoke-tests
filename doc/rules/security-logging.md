# Security and logging standards

Adapted for this repo from the DEFRA [security standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/security_standards.md), [logging standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/logging_standards.md), [security principles](https://github.com/DEFRA/software-development-standards/blob/main/docs/principles/security_principles.md) and [application credentials guide](https://github.com/DEFRA/software-development-standards/blob/main/docs/guides/application_credentials.md).

This repository is a test suite that calls a deployed service from outside. It serves no requests, stores no data and has no application logger, so the DEFRA rules about input validation, authentication handlers, structured application logs and log levels apply to `waste-organisations`, not here. What applies here is below.

## Secure coding

- Follow the [OWASP Secure Coding Practices quick reference guide](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/) (version 2).
- Secure development is everyone's concern; security is woven into everyday practice, not bolted on.
- The suite runs against every CDP environment, production included. A check only reads: it never creates, changes or deletes data in a deployed environment.
- A check sends exactly the credentials its spec states. "None" means no `Authorization` header, no API key and no cookie, so the check proves what an anonymous caller sees.
- Requests go to the host built from `ENVIRONMENT` or given in `SERVICE_BASE_URL`, and nowhere else. Never take a target URL from a response.

## Secrets and credentials

- This repository is public, and the test code is published in the open. Never commit a credential, token, API key, connection string or `.env` value.
- A check that needs credentials reads them from environment variables supplied to the suite as CDP secrets. Its spec names the variables, never the values.
- The values in `docker/config/defaults.env` are development-only placeholders for the local Compose stack. Never put a real credential in that folder or in `compose.yml`, and never reuse those values anywhere else.
- If a secret ever reaches git history, treat it as compromised and follow the DEFRA [credential exposure process](https://github.com/DEFRA/software-development-standards/blob/main/docs/processes/credential_exposure.md): rotate first, then clean the history.
- Never bypass GitHub push protection or dismiss a security alert without the approval described in [resolving GitHub security alerts](https://github.com/DEFRA/software-development-standards/blob/main/docs/processes/github_security_alerts.md).

## What the suite writes

The suite's output is the console of the CDP run and the Allure report, which `bin/publish-tests.sh` publishes to S3. Treat both as readable by anyone with access to the CDP Portal.

- A failure message names the URL requested and the status received, or the network error. It never includes a request header, a credential, a token or a response body.
- A URL that would carry a credential or personal data in its path or query string is not written to a message as it is; a check must not need one.
- Test titles, test data and report attachments carry no personal data and no secrets. Test data is synthetic: never a real organisation, address or person.
- `console` calls are lint errors (`no-console`). Do not add a logging library; a check speaks through its title and its assertion message.
- The CDP configuration takes a browser screenshot when a test fails. A check that drives the browser must not have a credential or personal data on screen at that point.

## GitHub security

Defra has GitHub Advanced Security enabled organisation-wide. Prefer its built-in features to third-party tools, and resolve open alerts in the repository's Security tab (Dependabot, code scanning, secret scanning) rather than leaving them to age.

The supply-chain settings in `.npmrc` and the action pinning rule are in [javascript-nodejs.md](javascript-nodejs.md) and [continuous-integration.md](continuous-integration.md).
