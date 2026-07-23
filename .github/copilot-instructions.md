# Redmine Wiki Extensions Plugin

This is a Redmine plugin (not a standalone Rails app). Full architecture reference: [AGENTS.md](../AGENTS.md).

## Mandatory Guards

Every macro and controller action must guard with:

```ruby
return nil unless WikiExtensionsUtil.is_enabled?(@project) if @project
```

For tag features, also add:

```ruby
return nil unless WikiExtensionsUtil.tag_enabled?(@project)
```

## After Every Code Change

Run YARD and confirm 100% coverage — CI enforces this:

```bash
cd /usr/local/redmine/plugins/redmine_wiki_extensions
yard stats --list-undoc
```

## Development Workflow

- **TDD**: Write a failing test first, then implement the minimum code to pass.
- **Coverage**: Maintain ≥ 90% test coverage (`COVERAGE=true` flag).

## Language Conventions

- All commit messages and source code comments must be in **English**.
- Commit format: `verb + brief description`, subject line ≤ 50 chars.
- PRs must target the `develop` branch.

## Key Gotchas

- Assets live in `assets/` — not Rails-standard `app/assets/`.
- Tables are prefixed `wiki_extensions_`; access settings via `WikiExtensionsSetting.find_or_create(project.id)`.
- The formatter patch handles two Redmine textile class layouts: `Formatter` (old) and `Filter` (new, since ~Jan 2026).
- i18n: use `l(:symbol)`, locale files in `config/locales/`.