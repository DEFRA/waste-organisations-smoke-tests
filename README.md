waste-organisations-smoke-tests

Post-deployment smoke tests for the `waste-organisations` API. The suite checks that the v1 and v2 API
documentation is served to anonymous callers: each OpenAPI document and each ReDoc page must return `200` with no
credentials and without following redirects.

- [What the suite checks](#what-the-suite-checks)
  - [Target host](#target-host)
- [Local Development](#local-development)
  - [Requirements](#requirements)
    - [Node.js](#nodejs)
  - [Setup](#setup)
  - [Running local tests](#running-local-tests)
- [Production](#production)
  - [Running the tests](#running-the-tests)
- [Requirements of CDP Environment Tests](#requirements-of-cdp-environment-tests)
- [Running on GitHub](#running-on-github)
- [Licence](#licence)
  - [About the licence](#about-the-licence)

## What the suite checks

| Request                         | Credentials | Expected |
| ------------------------------- | ----------- | -------- |
| `GET /openapi/v1.json`          | None        | `200`    |
| `GET /openapi/v2.json`          | None        | `200`    |
| `GET /redoc/index.html?spec=v1` | None        | `200`    |
| `GET /redoc/index.html?spec=v2` | None        | `200`    |

A redirect, any other status, a network error or a 30 second timeout fails the test. The failure message names the
URL requested.

### Target host

The suite targets the public API host of the CDP environment, so requests go through the API gateway:

```text
https://waste-organisations.api.${ENVIRONMENT}.cdp-int.defra.cloud
```

CDP supplies `ENVIRONMENT`. Set `SERVICE_BASE_URL` to override the host, for example to run against a local
instance. When `SERVICE_BASE_URL` is set, the suite uses its scheme and host and ignores `ENVIRONMENT`; any
path on it is ignored. When neither variable is set, or `SERVICE_BASE_URL` is not a valid URL, the suite fails before
it sends any request.

## Local Development

### Requirements

#### Node.js

Please install [Node.js](http://nodejs.org/) `>= v24` and [npm](https://nodejs.org/) `>= v11`. You will find it
easier to use the Node Version Manager [nvm](https://github.com/creationix/nvm)

To use the correct version of Node.js for this application, via nvm:

```bash
nvm use
```

### Setup

Install application dependencies:

```bash
npm install
```

### Running local tests

Point the suite at a running `waste-organisations` service with `SERVICE_BASE_URL`:

```bash
SERVICE_BASE_URL=<url> npm test
```

The tests are plain HTTP requests run with [Mocha](https://mochajs.org/); no browser is involved. To build the
Allure report from the results (needs a Java runtime):

```bash
npm run report
```

## Production

### Running the tests

Tests are run from the CDP-Portal under the Test Suites section. Before any changes can be run, a new docker image must be built, this will happen automatically when a pull request is merged into the `main` branch.
You can check the progress of the build under the actions section of this repository. Builds typically take around 1-2 minutes.

The results of the test run are made available in the portal.

## Requirements of CDP Environment Tests

1. Your service builds as a docker container using the `.github/workflows/publish.yml`
   The workflow tags the docker images allowing the CDP Portal to identify how the container should be run on the platform.
   It also ensures its published to the correct docker repository.

2. The Dockerfile's entrypoint script should return exit code of 0 if the test suite passes or 1/>0 if it fails

3. Test reports should be published to S3 using the script in `./bin/publish-tests.sh`

## Running on GitHub

Test runs on GitHub cannot connect to the CDP environments. Instead, the pull request check starts the latest
published `waste-organisations` image with [compose.yml](compose.yml) and runs the suite against it. This checks
the service itself; requests do not go through the API gateway.

The stack is the service, MongoDB and Postgres. Liquibase applies the service's Postgres schema, which is the
`changelog/` folder of the [waste-organisations](https://github.com/DEFRA/waste-organisations) repository.

To do the same locally:

```bash
npm run stack:up
```

```bash
npm run test:github
```

```bash
npm run stack:down
```

`npm run stack:up` fetches the changelog into `.waste-organisations/` before starting the containers. Two variables
change what is tested:

| Variable                        | Effect                                                                                                                                    |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `WASTE_ORGANISATIONS`           | Image tag to test, for example `0.136.0`. The changelog is fetched at the same tag. Defaults to `latest`, with the changelog from `main`. |
| `WASTE_ORGANISATIONS_CHANGELOG` | Path to a changelog folder to use as it is, for example `../waste-organisations/changelog`. Nothing is fetched.                           |

## Licence

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government licence v3

### About the licence

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable
information providers in the public sector to license the use and re-use of their information under a common open
licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
