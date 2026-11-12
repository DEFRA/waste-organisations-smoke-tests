# Container standards

Adapted for this repo from the DEFRA [container standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/container_standards.md), [deployment standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/deployment_standards.md) and [Docker guidance](https://github.com/DEFRA/software-development-standards/blob/main/docs/guides/docker_guidance.md).

## Standards

- The suite is delivered as a Docker image, built with Docker by the CDP build action on merge to `main` (`.github/workflows/publish.yml`). Linux containers only.
- The image is not a service. The CDP Portal starts a container, `entrypoint.sh` runs the suite, publishes the report and exits with the result. It listens on no port and has no health check.
- The image is **immutable**: once built it does not change, but it is configured. Everything that differs between runs comes from environment variables CDP sets (the environment, the proxy, the chromedriver address, the report location), never from values baked into the image.
- The image is **self-contained** and carries what a run needs: the npm dependencies, a Java runtime for the Allure report and the AWS CLI for publishing it. Add to it only what a run needs.
- The `Dockerfile` is the source of truth for the build. The Node version in its `FROM` line and the version in `.nvmrc` are the same: change them together.
- The image is tagged and published by the CDP build action; nothing in this repository sets a tag.

## Accepted deviations (recorded 12 November 2026)

The DEFRA standard asks for images that extend the Defra parent images (`defradigital/node`) and for containers that do not run as root. This repo keeps the `Dockerfile` of the [CDP journey test suite template](https://github.com/DEFRA/cdp-node-journey-test-suite-template) unchanged instead (the two files were identical on 12 November 2026), because CDP builds and runs every test suite from that layout and supports the template as it is:

- **The base image is the official `node` slim image** from Docker Hub, pinned by exact version tag, not `defradigital/node`. The template uses it.
- **The container runs as root.** The `Dockerfile` sets `USER root` to install the Java runtime and the AWS CLI and does not switch back. The container is short-lived and serves no traffic. Running it as a non-root user is a change to raise with CDP, not one to make in passing, because report publishing and the platform's run status would need verifying.
- **It is a single-stage build that copies the whole repository and runs `npm install`**, where the DEFRA Docker guidance asks for multi-stage builds and the Node.js standard asks for `npm ci` in a production build. The suite is the source, so there is no build output to separate from it.

Record any further deviation here with the date and the reason, and revisit these when the CDP template changes.

## Local stack (`compose.yml`)

- `compose.yml` and `docker/` are the template's Compose stack for running a suite on a GitHub runner. They do not start `waste-organisations`, and the smoke checks do not need them: a local run targets a service started from its own repository (see "Local Commands" in `AGENTS.md`).
- The values in `docker/config/` are development-only. Never put a real credential in a Compose file or an env file.
