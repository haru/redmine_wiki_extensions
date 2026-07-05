---
name: create-pr
description: Open a GitHub pull request for the current branch of this repository using the gh CLI, following this repo's branch conventions — release/* branches target main with a title/body of "Release <version>" (version read from init.rb), while every other branch targets develop with an auto-generated title, a bullet-point summary of the branch's changes, and an enhancement/bug/documentation label. Use this whenever the user asks to open, create, or submit a pull request or PR, says "gh pr create", or asks in Japanese to "PRを作って" / "プルリクを作成して" / "プルリクエストを出して".
---

# Create a pull request for this repo

This repo has two very different PR shapes depending on the branch, and the
right one only becomes obvious after you know which branch you're on. Work
through the steps below in order — don't skip straight to `gh pr create`.

## 1. Figure out the branch and its target

```bash
git branch --show-current
```

- Branch starts with `release/` → this is a **release PR**, target `main`.
- Anything else → this is a **regular PR**, target `develop`.

This distinction matters beyond just the `--base` flag: it changes where the
title/body come from (steps 2 vs 3).

Before drafting anything, sync so the diff you read is accurate:

```bash
git fetch origin main develop
```

## 2. Release PR (branch matches `release/*`)

The release number is not the branch name — it's whatever `init.rb` actually
declares as the plugin version, since that's the single source of truth the
release process cuts a tag from. Read it with the bundled script rather than
grepping ad hoc, since the `requires_redmine version_or_higher: ...` line
sits right next to the real version and is easy to match by mistake:

```bash
.claude/skills/create-pr/scripts/get_plugin_version.sh init.rb
```

Use the result to build:
- **Base**: `main`
- **Title**: `Release <version>` (e.g. `Release 1.2.0`)
- **Body**: same text as the title, `Release <version>`
- **Labels**: none, unless the user asks for one

Skip straight to step 4 (confirm) — there's no change summary or label
classification to do for a release PR.

## 3. Regular PR (any other branch)

### Title and body from the actual diff

Look at what the branch changed relative to `develop`, not just the commit
messages (a branch may have messy WIP commits that don't reflect the final
change):

```bash
git log origin/develop..HEAD --oneline
git diff origin/develop...HEAD --stat
```

Read enough of the diff to understand the change, then write:
- **Title**: a single imperative sentence describing the change, in the same
  style as this repo's commit messages (verb + brief description, e.g. "Fix
  compatibility with Redmine master", "Add view_wiki_pages permission").
  Keep it under ~70 characters.
- **Body**: a short bullet list of what changed, in English, e.g.:
  ```
  - Add X macro for embedding Y
  - Update init.rb permissions to include Z
  ```
  Bullets should describe the *change*, not restate the diff line by line.

### Choosing a label

Classify the change by what it does to the codebase, not by keywords alone:

- **enhancement** — adds or extends functionality (new macro, new setting,
  new permission, new behavior).
- **bug** — fixes incorrect behavior (something that used to misbehave now
  doesn't).
- **documentation** — only touches docs/comments (README, CLAUDE.md, YARD
  comments) with no behavior change.

If the branch mixes categories, pick the label matching its primary intent
and mention the reasoning briefly when you confirm with the user.

Not every change fits one of these three buckets — pure CI/tooling/dependency
bumps (e.g. adding a Ruby or Redmine version to the test matrix) are neither
a feature, a fix, nor documentation. Don't force a mismatched label onto
those; leave the PR unlabeled instead. This matches how past PRs of that kind
in this repo (e.g. #44, #45) were merged without a label.

`documentation` doesn't exist as a label in every repo yet. Check first, and
create it only if it's missing:

```bash
gh label list --json name -q '.[].name'
# if "documentation" isn't in the list:
gh label create documentation --color 0075ca --description "Improvements or additions to documentation"
```

Don't recreate `bug` or `enhancement` — they already exist in this repo with
project-specific colors.

## 4. Confirm before creating

A PR is visible to other people the moment it's opened, so before running
`gh pr create` show the user the drafted base/title/body/label and get a
go-ahead — don't fire-and-forget one. This includes when the branch still
needs a push:

```bash
git push -u origin "$(git branch --show-current)"   # only if not already pushed
```

## 5. Create the PR

```bash
gh pr create --base <main|develop> --title "<title>" --body "<body>" --label "<label>"
```

Omit `--label` entirely for release PRs. After it's created, report the PR
URL back to the user.
