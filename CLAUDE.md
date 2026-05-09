# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Redmine plugin (not a standalone Rails app) that extends wiki functionality with macros, comments, tagging, voting, and enhanced formatting. It must run inside a Redmine installation — there is no standalone `rails server`.

## Running Tests

Tests require a full Redmine checkout. The `build-scripts/` directory handles this for CI:

```bash
# One-time setup: clones Redmine, copies fixtures, runs migrations
cd build-scripts && ./install.sh

# Run the full test suite (must be run from inside PATH_TO_REDMINE)
cd $PATH_TO_REDMINE
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions

# Run a single test file
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions TEST=plugins/redmine_wiki_extensions/test/unit/wiki_extensions_tag_test.rb
```

Required environment variables (all must be absolute paths):
- `TESTSPACE` — scratch directory for the test environment
- `PATH_TO_REDMINE` — where Redmine is checked out
- `PATH_TO_PLUGIN` — path to this plugin directory

The devcontainer pre-configures these via `build-scripts/env.sh`. In the devcontainer, Redmine is at `/usr/local/redmine` and the plugin is mounted at `/usr/local/redmine/plugins/redmine_wiki_extensions`.

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

## Critical Patterns

**Module enablement check** — every macro and controller action must guard with:
```ruby
return nil unless WikiExtensionsUtil.is_enabled?(@project) if @project
```

**Tag enablement check**:
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

## Development Approach

Use test-driven development: write a failing test first, then implement the minimum code to make it pass, then refactor.

Maintain test coverage at 90% or above. Coverage reports are generated in `coverage/` when running tests with `COVERAGE=true`:

```bash
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions COVERAGE=true
```

## Adding a New Macro

1. Create `lib/wiki_extensions_[name]_macro.rb`
2. Register with `Redmine::WikiFormatting::Macros.register do ... end` inside a module
3. Add tests in `test/unit/`
4. If new permissions are needed, add to `init.rb`

## Git and Language Conventions

- All commit messages must be in **English**
- All source code comments must be in **English**
- All PRs must target the `develop` branch (a CI workflow blocks PRs to `main`/`master`)
- Commit message format: `verb + brief description`, subject line under 50 characters

## CI Matrix

GitHub Actions builds against:
- Ruby: 3.1, 3.2, 3.3, 3.4
- Redmine: 6.0-stable, 6.1-stable, master
- DB: sqlite3, mysql, postgres

Some combinations are excluded (e.g., Ruby 3.4 + Redmine 6.0-stable).
