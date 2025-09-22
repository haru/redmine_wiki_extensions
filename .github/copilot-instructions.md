# Redmine Wiki Extensions Plugin - AI Coding Guidelines

## Project Architecture

This is a **Redmine plugin** (not a standalone Rails app) that extends wiki functionality with macros, comments, tags, and voting. The plugin follows Redmine's plugin architecture patterns:

- `init.rb` - Plugin registration, permissions, and menu definitions
- `lib/` - Wiki macros and patches to Redmine core classes
- `app/` - Standard Rails MVC structure for additional features
- `db/migrate/` - Database migrations for plugin-specific tables

## Key Components

### Wiki Macros (`lib/*_macro.rb`)
All macros follow this pattern:
```ruby
module WikiExtensions[Name]Macro
  Redmine::WikiFormatting::Macros.register do
    desc "Macro description"
    macro :macro_name do |obj, args|
      # Implementation
    end
  end
end
```

**Important macros**: `count`, `wiki`, `tags`, `recent`, `vote`, `project`, `twitter`

### Patches (`lib/*_patch.rb`)
Extend Redmine core functionality using Rails' `prepend` pattern. Key patches:
- `wiki_extensions_wiki_controller_patch.rb` - Adds functionality to WikiController
- `wiki_extensions_formatter_patch.rb` - Extends wiki formatting
- `wiki_extensions_helper_patch.rb` - Adds helper methods

### Models (`app/models/`)
Plugin-specific models with Redmine associations:
- `WikiExtensionsComment` - Hierarchical comments on wiki pages
- `WikiExtensionsTag` - Tagging system for wiki pages
- `WikiExtensionsVote` - Voting/rating system

## Development Workflows

### Testing
- Use `bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions` 
- Tests require Redmine environment setup via `build-scripts/install.sh`
- Coverage reports generated in `coverage/` directory
- Test fixtures in `test/fixtures/` must be copied to Redmine's test/fixtures/

### Database Changes
- Always create migrations in `db/migrate/` with sequential numbering
- Use `rake redmine:plugins:migrate` for deployment
- Model tables prefixed with `wiki_extensions_`

### Build Process
The plugin uses a complex CI setup:
- Matrix builds across Ruby 3.1-3.4 and Redmine 6.0-master
- Tests against SQLite, MySQL, PostgreSQL
- Build scripts in `build-scripts/` handle Redmine checkout and plugin setup

## Coding Patterns

### Permission Checks
Always check permissions before displaying features:
```ruby
return nil unless WikiExtensionsUtil.is_enabled?(@project) if @project
User.current.allowed_to?({controller: 'wiki_extensions', action: 'action'}, @project)
```

### View Helpers
- Complex HTML generation in `lib/wiki_extensions_helper.rb`
- Tree-like comment display with JavaScript interaction
- Contextual menus with permission-based visibility

### Internationalization
- Locale files in `config/locales/`
- Use `l(:symbol)` for translations
- Support for 10+ languages

### JavaScript/CSS
- Assets in `assets/` directory (not Rails standard `app/assets/`)
- jQuery-based interactions
- Separate stylesheets for print (`wiki_extensions_print.css`)

## Integration Points

### With Redmine Core
- Hooks in `lib/wiki_extensions_application_hooks.rb`
- Menu integration via `menu :project_menu` in `init.rb`
- Activity provider for comment notifications
- Email notifications via `WikiExtensionsCommentsMailer`

### Plugin Settings
- Per-project settings via `WikiExtensionsSettingsController`
- Settings stored in `wiki_extensions_settings` table
- Feature toggles for different functionality

## Common Tasks

### Adding New Macro
1. Create `lib/wiki_extensions_[name]_macro.rb`
2. Follow macro registration pattern
3. Add tests in `test/unit/`
4. Update permissions in `init.rb` if needed

### Adding Model/Feature
1. Create migration in `db/migrate/`
2. Add model in `app/models/` with proper associations
3. Add controller actions if web interface needed
4. Update permissions and routes

### Debugging
- Plugin works "only on production mode" (per README)
- Use Rails logger: `Rails.logger.info`
- Check `WikiExtensionsUtil.is_enabled?` for feature availability