# Common coding standards

Adapted for this repo from the DEFRA [common coding standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/common_coding_standards.md) and [coding principles](https://github.com/DEFRA/software-development-standards/blob/main/docs/principles/coding_principles.md).

## Principles

- **Main is always shippable**: every merge to `main` builds the image the CDP Portal runs, so `main` is always in a state that can be run against any environment: styled, documented and passing against a healthy service.
- **The code is not yours**: write and commit code for the next developer, who will not have your context. They must be able to derive intent from the code alone.
- **Work in the open**: code is open as early as possible; going private is the managed exception. This repo is public.
- **Code securely** and **we test our code**: here the code is the tests, so a check is proven by running it (see "Verified" in [quality-assurance.md](quality-assurance.md)).

## Standards

- All coding is done on a branch; no changes directly to `main`.
- All code is reviewed by another developer before merge.
- Test code meets the same standards as production code: it is linted, formatted and reviewed the same way.
- The DEFRA standard asks for 90% unit test coverage. This repository is the test suite and has no production code, so there are no unit tests and no coverage figure to hold; do not add tests of the tests to produce one.

## Readability

- No generic names: `p`, `temp`, `v`, `data2`, `x`.
- Prefer objects with named keys over positional arrays: `{ path, expectedStatus }` reads; `['/openapi/v1.json', 200]` does not.
- Avoid unexplained acronyms, especially domain-specific ones (CDP, EPR). Spell one out where it is first used in a file.
- Name things for the intent of the thing and the person who comes after you, not what makes sense to you today. A test title states the request and the expected result, because it is what the report shows.
- Stick to the conventions already encoded in `.editorconfig`, `.prettierrc.js`, `eslint.config.js` and the existing spec files.
- **Separate in order to name**: break code into small functions whose names express intent. Aim for code that needs no comments.

### Comments (when unavoidable)

- Comments are code: keep them small and refactor them as the code changes.
- Document _why_ the thing is needed or why it is done this way, never the _how_.
- Comment in the right place: a decision where it bites. Point at the spec that made the decision.
- Only write about the code: no names, dates, commit references or opinions.
- Never leave commented-out code; git history is the record.
- Write comments as you write the code, or you never will.

## Simplicity

- Do not code for reuse until there is a confirmed need for reuse.
- Apply the [rule of three](<https://en.wikipedia.org/wiki/Rule_of_three_(computer_programming)>) before abstracting: a helper, a page object or a shared module is extracted when the third use arrives, not the first.
- A check that needs one request is one request. Do not build a framework around it.

## Documentation and licensing

- Document the _how_ for the project: what the suite checks, which host it targets and how to run it. The README follows the DEFRA [README standards](https://github.com/DEFRA/software-development-standards/blob/main/docs/standards/readme_standards.md); update it when a check, the setup or the run steps change.
- Design decisions live in `specs/` (see "Specs" in `AGENTS.md`), not in chat history or commit messages alone.
- The repo carries the Open Government Licence v3 (`LICENCE`) and the README states the licence and the attribution statement.
