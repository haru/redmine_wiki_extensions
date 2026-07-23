# AGENTS.md

Guidance for AI agents working in this Redmine plugin.

## What This Is

A Redmine plugin (not a standalone Rails app) that extends wiki functionality with macros, comments, tagging, voting, and enhanced formatting. It cannot run standalone — it must run inside a Redmine installation; there is no standalone `rails server`.

## Environment Setup

Tests require a full Redmine checkout. The `build-scripts/` directory handles this for CI:

```bash
# One-time setup: clones Redmine, copies fixtures, runs migrations
cd build-scripts && ./install.sh
```

Required environment variables (all must be absolute paths):
- `TESTSPACE` — scratch directory for the test environment
- `PATH_TO_REDMINE` — where Redmine is checked out
- `PATH_TO_PLUGIN` — path to this plugin directory

The devcontainer pre-configures these via `build-scripts/env.sh`. In the devcontainer, Redmine is at `/usr/local/redmine` and the plugin is mounted at `/usr/local/redmine/plugins/redmine_wiki_extensions`. The devcontainer sets up MySQL, PostgreSQL, and SQLite databases automatically via `post-create.sh`.

## Commands

```bash
# Full test suite (must run from inside Redmine root, not the plugin dir)
cd /usr/local/redmine
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions

# Single test file
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions TEST=plugins/redmine_wiki_extensions/test/unit/wiki_extensions_tag_test.rb

# YARD doc check — CI enforces 100% documented. Must pass before any change is complete.
yard stats --list-undoc

# Coverage report (generated in coverage/)
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions COVERAGE=true
```

## Testing

Tests use `simplecov` + `shoulda` gems. Test fixtures in `test/fixtures/` are copied into Redmine's `test/fixtures/` during setup.

Plugin-only fixtures (declared with `fixtures :wiki_extensions_*`): `wiki_extensions_comments`, `wiki_extensions_counts`, `wiki_extensions_menus`, `wiki_extensions_settings`, `wiki_extensions_tag_relations`, `wiki_extensions_tags`, `wiki_extensions_votes`. Redmine core fixtures (`projects`, `users`, `wikis`, etc.) are declared separately and already exist in Redmine's test environment.

**Test directory structure**:
- `test/unit/` — model tests (`ActiveSupport::TestCase`), using `shoulda` `context`/`should` blocks
- `test/functional/` — controller tests (`ActionController::TestCase`)

**Enabling the plugin module in a test** (required for integration tests):
```ruby
EnabledModule.create!(project_id: 1, name: 'wiki_extensions')
```

## Architecture

### Plugin Loading (`init.rb`)
- Requires all `lib/*.rb` files at boot
- Registers permissions under the `wiki_extensions` project module
- Adds up to 5 configurable project menu items
- Registers `wiki_comment` as a Redmine activity provider

### Macros (`lib/*_macro.rb`)
Each macro file registers one or more macros with `Redmine::WikiFormatting::Macros.register`. Macro blocks receive `(obj, args)` where `obj` is the wiki content object and `obj.page` is the wiki page.

### Patches (`lib/*_patch.rb`)
Extend Redmine core using `prepend`. Key patches:
- `wiki_extensions_wiki_controller_patch.rb` — prepends `WikiController`; uses `after_action :wiki_extensions_save_tags` and overrides `render`/`respond_to` to inject headers, footers, and footnote lists
- `wiki_extensions_formatter_patch.rb` — prepends the textile formatter to add emoticon rendering; handles both old (`Formatter`) and new (`Filter`) Redmine textile class layouts (split in Redmine ~Jan 2026)
- `wiki_extensions_helper_patch.rb` — adds helper methods to Redmine's wiki helpers

### Application Hooks (`lib/wiki_extensions_application_hooks.rb`)
Injects partials into Redmine's layout via `render_on`:
- `view_layouts_base_html_head` → `wiki_extensions/html_header`
- `view_layouts_base_body_bottom` → `wiki_extensions/body_bottom`

### Models (`app/models/`)
All tables are prefixed `wiki_extensions_`. Key models:
- `WikiExtensionsComment` — hierarchical (parent_id) comments on wiki pages
- `WikiExtensionsTag` / `WikiExtensionsTagRelation` — tagging system
- `WikiExtensionsVote` — per-user votes on pages
- `WikiExtensionsSetting` — per-project feature toggles; use `WikiExtensionsSetting.find_or_create(project.id)`
- `WikiExtensionsMenu` — configurable project menu items

### Settings
Per-project settings are stored in `wiki_extensions_settings`. Access via `WikiExtensionsSetting.find_or_create(project.id)`. Feature toggles include `tag_disabled` and others.

### Assets
Assets live in `assets/` (not `app/assets/`).

## Critical Patterns

**Module enablement check** — every macro and controller action must guard with:
```ruby
return nil unless WikiExtensionsUtil.is_enabled?(@project) if @project
```

**Tag enablement check** (for tag features, additionally):
```ruby
return nil unless WikiExtensionsUtil.tag_enabled?(@project)
```

**Permission check** (after module enablement):
```ruby
User.current.allowed_to?({controller: 'wiki_extensions', action: 'action'}, @project)
```

**Session-based state** (e.g., access counting):
```ruby
session[:access_count_table] ||= {}
unless session[:access_count_table][page.id]
  WikiExtensionsCount.countup(page.id)
  session[:access_count_table][page.id] = 1
end
```

## Development Workflow

Use test-driven development: write a failing test first, then implement the minimum code to make it pass, then refactor. Never write implementation before a test.

Maintain test coverage at 90% or above (run with `COVERAGE=true` to generate reports in `coverage/`).

### Adding a New Macro

1. Create `lib/wiki_extensions_[name]_macro.rb`
2. Register with `Redmine::WikiFormatting::Macros.register do ... end` inside a module
3. Add tests in `test/unit/`
4. If new permissions are needed, add to `init.rb`

### After Modifying Code

After every code change, run YARD to confirm no documentation errors were introduced:

```bash
cd /usr/local/redmine/plugins/redmine_wiki_extensions
yard stats --list-undoc
```

This must exit without errors before the change is considered complete.

## CI Requirements

- **YARD coverage must be 100%** — CI step `yard stats --list-undoc` fails if not.
- Matrix: Ruby 3.1–3.4, Redmine 6.0-stable/6.1-stable/master, sqlite3/mysql/postgres.
- Exclusions: Ruby 3.1 excluded from 6.1-stable and master; Ruby 3.4 excluded from 6.0-stable.
- PRs must target `develop` branch — a workflow auto-closes PRs to `main`.

## Git Conventions

- **NEVER commit or push without explicit user permission.** This includes `git commit`, `git push`, force pushes, reverts, and any other operation that modifies the repository history or the remote — always show what will be done and get approval first. This applies even when undoing your own previous commits.
- English-only commit messages and source comments.
- Format: `verb + brief description`, subject line under 50 chars.
- Target `develop` branch for all PRs.
