---
name: commit
description: Use this skill when you need to commit code changes with properly formatted commit messages that follow conventional commit standards. Use it when you have finished implementing a check, fixed a bug, or have any other change ready to save. Produces fine-grained atomic commits with short imperative subjects and an optional short body.
allowed-tools: Bash
---

You are an expert Git committer who creates commit messages following the Conventional Commits specification (https://www.conventionalcommits.org/en/v1.0.0/).

Use plain `git` commands.

## Commit Message Format

```
<type>[optional scope]: <description>

[optional short body: up to 3 bulleted lines]

[optional footer(s)]
```

## Commit Types

| Type     | Purpose                                         | SemVer |
| -------- | ----------------------------------------------- | ------ |
| feat     | New feature                                     | MINOR  |
| fix      | Bug fix                                         | PATCH  |
| docs     | Documentation only                              | -      |
| style    | Formatting/linting, whitespace (no code change) | -      |
| refactor | Code restructuring (no feature/fix)             | -      |
| perf     | Performance improvement                         | -      |
| test     | Adding or correcting tests                      | -      |
| build    | Build system or dependencies                    | -      |
| ci       | CI configuration                                | -      |
| chore    | Maintenance tasks                               | -      |

In this repository the checks are the product: a new or changed smoke check is `test`, with a scope that names the area (`test(smoke): ...`).

## Breaking Changes

Indicate breaking changes using either:

- Append `!` after type/scope (e.g., `build!: replace the test runner`)
- Add footer with `BREAKING CHANGE: description of what broke`

## Rules

1. **Analyse changes**: review `git status` and `git diff` before composing anything.
2. **Atomic commits**: each commit captures one logical change. If the working tree contains separable concerns (e.g. a refactor _and_ the check it enables, or two unrelated fixes), produce multiple commits, one per concern, rather than a single grab-bag commit.
3. **Stage selectively**: pass explicit paths to `git add -- <paths>`. Never use `git add -A` or `git add .` when the diff spans multiple logical changes.
4. **Check recent commits**: `git log --oneline -10` to match the project's prevailing style before writing your own subject.
5. **Select type**: pick the most specific type that fits the change.
6. **Optional scope**: parenthetical, lowercase, names the affected area (e.g. `test(smoke):`, `docs(readme):`).
7. **Subject**: imperative mood, lowercase, ≤50 characters, no trailing period. No Jira key: the key belongs to the pull request title (`doc/rules/git-workflow.md`).
8. **Body (optional)**: at most **3 short bulleted lines** summarising what was implemented. Use a body only when the subject alone doesn't make the change self-evident. Skip the body entirely for trivial or self-describing diffs.
9. **Never stage loop or local artefacts**: `IMPLEMENTATION_PLAN.md`, `PROGRESS.md`, `PROMPT_*.md`, `ralph.yaml`, `.ralph/`, `allure-results/`, `allure-report/`, `FAILED`. They are gitignored; if one shows as tracked, stop and ask.
10. **Respect the hook**: the pre-commit hook runs the gate (`npm run format:check` and `npm run lint`). If it fails, fix the cause and commit again; never pass `--no-verify`.
11. **Commit immediately**: do not seek approval before committing. The user invoked this skill _because_ they want a commit.

## Quality Standards

- No tool signatures or co-author trailers in commit messages
- Keep the subject ≤50 characters where possible
- One logical change per commit: split larger diffs into multiple atomic commits in a single skill invocation
- The body, when present, is **at most 3 bulleted lines**; no prose paragraphs, no long explanations
- Ignore previous commit messages when composing new ones: match style, not content

## Examples

Subject only (preferred for self-evident diffs):

```
test(smoke): add api doc smoke tests
```

```
fix(smoke): name the url in the timeout message
```

Subject with short bulleted body (when the diff isn't self-explanatory):

```
build(test): route node fetch through env proxy

- set NODE_USE_ENV_PROXY on the wdio command
- keep the clean step outside the prefix
```

Breaking change:

```
build!: replace the test runner
```

## Tool reference

- `git status`: inspect the working tree
- `git diff` / `git diff --staged`: review unstaged and staged changes
- `git log --oneline -10`: recent commit style
- `git add -- <paths>`: stage specific paths only (never `-A` / `.` for multi-concern diffs)
- Use a HEREDOC for the commit message so the subject and body bullets keep their newlines:

  ```bash
  git commit -m "$(cat <<'EOF'
  <type>(<scope>): <subject>

  - bullet one
  - bullet two
  EOF
  )"
  ```

If the intent or scope of the changes is unclear, ask specific questions before committing.
