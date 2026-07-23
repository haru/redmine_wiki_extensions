# AGENTS.md

Quick-reference for AI agents working in this Redmine plugin.

## What This Is

A Redmine plugin that extends wiki with macros, comments, tagging, voting, and formatting. It cannot run standalone — it lives inside a Redmine installation.

## Devcontainer Layout

In the devcontainer: Redmine is at `/usr/local/redmine`, this plugin is at `/usr/local/redmine/plugins/redmine_wiki_extensions`. The devcontainer sets up MySQL, PostgreSQL, and SQLite databases automatically via `post-create.sh`.

## Commands

```bash
# Full test suite (must run from inside Redmine root, not the plugin dir)
cd /usr/local/redmine
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions

# Single test file
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions TEST=plugins/redmine_wiki_extensions/test/unit/wiki_extensions_tag_test.rb

# YARD doc check — CI enforces 100% documented. Must pass before any change is complete.
yard stats --list-undoc

# Coverage report
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions COVERAGE=true
```

Tests use `simplecov` + `shoulda` gems. Test fixtures in `test/fixtures/` are copied into Redmine's `test/fixtures/` during setup.

Plugin-only fixtures (declared with `fixtures :wiki_extensions_*`): `wiki_extensions_comments`, `wiki_extensions_counts`, `wiki_extensions_menus`, `wiki_extensions_settings`, `wiki_extensions_tag_relations`, `wiki_extensions_tags`, `wiki_extensions_votes`. Redmine core fixtures (`projects`, `users`, `wikis`, etc.) are declared separately and already exist in Redmine's test environment.

**Test directory structure**:
- `test/unit/` — model tests (`ActiveSupport::TestCase`), using `shoulda` `context`/`should` blocks
- `test/functional/` — controller tests (`ActionController::TestCase`)

**Enabling the plugin module in a test** (required for integration tests):
```ruby
EnabledModule.create!(project_id: 1, name: 'wiki_extensions')
```

## Key Architecture Facts

- **`init.rb`** — plugin entrypoint. Requires all `lib/*.rb` at boot, registers permissions under `wiki_extensions` project module, adds up to 5 project menu items.
- **`lib/*_macro.rb`** — wiki macros registered via `Redmine::WikiFormatting::Macros.register`. Blocks receive `(obj, args)` where `obj.page` is the wiki page.
- **`lib/*_patch.rb`** — extend Redmine core via `prepend`. The formatter patch handles two Redmine textile class layouts (`Formatter` and `Filter`, split ~Jan 2026).
- **`app/models/`** — all tables prefixed `wiki_extensions_`. Per-project settings via `WikiExtensionsSetting.find_or_create(project.id)`.
- **Assets** live in `assets/` (not `app/assets/`).

## Mandatory Guard Patterns

Every macro and controller action must check module enablement:

```ruby
return nil unless WikiExtensionsUtil.is_enabled?(@project) if @project
```

For tag features, additionally:

```ruby
return nil unless WikiExtensionsUtil.tag_enabled?(@project)
```

Permission checks go after enablement:

```ruby
User.current.allowed_to?({controller: 'wiki_extensions', action: 'action'}, @project)
```

## Development Workflow

Use test-driven development: write a failing test first, then implement the minimum code to pass, then refactor. Never write implementation before a test.

For extended architecture details (session-state patterns, view hook details, mailer setup), see [CLAUDE.md](CLAUDE.md).

## CI Requirements

- **YARD coverage must be 100%** — CI step `yard stats --list-undoc` fails if not.
- Matrix: Ruby 3.1–3.4, Redmine 6.0-stable/6.1-stable/master, sqlite3/mysql/postgres.
- Exclusions: Ruby 3.1 excluded from 6.1-stable and master; Ruby 3.4 excluded from 6.0-stable.
- PRs must target `develop` branch — a workflow auto-closes PRs to `main`.

## Git Conventions

- English-only commit messages and source comments.
- Format: `verb + brief description`, subject line under 50 chars.
- Target `develop` branch for all PRs.
