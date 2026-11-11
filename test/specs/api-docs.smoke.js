import assert from 'node:assert/strict'

const DOC_VERSIONS = ['v1', 'v2']

if (!process.env.SERVICE_BASE_URL && !process.env.ENVIRONMENT) {
  throw new Error(
    'Set SERVICE_BASE_URL or ENVIRONMENT to choose the host for the API doc smoke tests'
  )
}

const baseUrl = (
  process.env.SERVICE_BASE_URL ||
  `https://waste-organisations.api.${process.env.ENVIRONMENT}.cdp-int.defra.cloud`
).replace(/\/+$/, '')

async function fetchStatus(url) {
  try {
    const response = await fetch(url, {
      redirect: 'manual',
      signal: AbortSignal.timeout(30000)
    })
    return response.status
  } catch (error) {
    throw new Error(`Request to ${url} failed: ${error.message}`, {
      cause: error
    })
  }
}

describe('API docs', () => {
  for (const version of DOC_VERSIONS) {
    for (const path of [
      `/openapi/${version}.json`,
      `/redoc/index.html?spec=${version}`
    ]) {
      it(`GET ${path} returns 200 without credentials`, async () => {
        const url = `${baseUrl}${path}`
        const status = await fetchStatus(url)
        assert.equal(status, 200, `Expected 200 from ${url} but got ${status}`)
      })
    }
  }
})
