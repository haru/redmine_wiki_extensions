# Redmine Wiki Extensions Plugin

[![build](https://github.com/haru/redmine_wiki_extensions/actions/workflows/build.yml/badge.svg)](https://github.com/haru/redmine_wiki_extensions/actions/workflows/build.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/35932ef513dece9c304c/maintainability)](https://codeclimate.com/github/haru/redmine_wiki_extensions/maintainability)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/haru/redmine_wiki_extensions)
[![codecov](https://codecov.io/gh/haru/redmine_wiki_extensions/branch/develop/graph/badge.svg?token=8WUARY4BRK)](https://codecov.io/gh/haru/redmine_wiki_extensions)

A comprehensive Redmine plugin that extends wiki functionality with powerful macros, comments, tagging, voting, and enhanced formatting capabilities.

## 🌟 Features

### Wiki Macros
- **Count Macro** - Display and track page access counts
- **Recent Macro** - Show recently updated wiki pages  
- **New Macro** - Highlight newly created content
- **Tags Macro** - Display and manage page tags
- **Vote Macro** - Enable voting/rating on wiki pages
- **Project Macro** - Display project information and links
- **Twitter Macro** - Embed Twitter content
- **Wiki Macro** - Enhanced wiki page linking
- **Iframe Macro** - Embed external content
- **Page Break Macro** - Add print-friendly page breaks
- **Div Macros** - Add custom HTML div containers
- **Last Updated Macros** - Show when/who last updated pages

### Additional Features
- **Hierarchical Comments** - Add threaded comments to wiki pages
- **Tagging System** - Organize pages with tags and tag-based navigation
- **Voting/Rating** - Allow users to rate wiki pages
- **Email Notifications** - Get notified about comment activity
- **Enhanced Formatting** - Extended wiki formatting capabilities
- **Emoticons Support** - Add emotional expressions to content
- **Footnotes** - Create academic-style footnotes
- **Responsive Design** - Mobile-friendly interface

### Internationalization
Supports 14+ languages including:
- English, Japanese, German, French, Spanish, Italian
- Portuguese, Russian, Korean, Chinese, and more

## 📋 Requirements

- **Redmine**: 6.0.0 or higher
- **Ruby**: 3.1 or higher
- **Rails**: Compatible with Redmine's Rails version

## 🚀 Installation

### 1. Download the Plugin

```bash
cd /path/to/redmine/plugins
git clone https://github.com/haru/redmine_wiki_extensions.git
```

### 2. Install Dependencies

```bash
cd /path/to/redmine
bundle install
```

### 3. Run Migration

```bash
rake redmine:plugins:migrate RAILS_ENV=production
```

### 4. Restart Redmine

Restart your Redmine server to load the plugin.

### 5. Enable the Module

1. Go to your project settings
2. Select the "Modules" tab
3. Enable "Wiki Extensions" module
4. Configure permissions under "Roles and permissions"

## ⚙️ Configuration

### Project Settings

After enabling the module, configure plugin settings:

1. Navigate to **Project Settings → Wiki Extensions**
2. Available options:
   - Enable/disable auto preview
   - Configure sidebar display
   - Enable/disable tagging functionality
   - Set up voting permissions
   - Configure comment notifications

### Permissions

Configure user permissions for:
- **Wiki Extensions Vote** - Allow voting on wiki pages
- **Add Wiki Comments** - Add comments to wiki pages
- **Delete Wiki Comments** - Remove comments
- **Edit Wiki Comments** - Modify existing comments
- **Manage Wiki Extensions** - Configure plugin settings

## 📖 Usage Examples

### Basic Macros

```textile
{{count}}                    # Display page access count
{{recent}}                   # Show recent wiki pages
{{recent(10)}}               # Show 10 most recent pages
{{new}}                      # Highlight new pages
{{tags}}                     # Display page tags
{{vote}}                     # Add voting interface
```

### Advanced Macros

```textile
{{project}}                  # Display current project info
{{project(ProjectName)}}     # Display specific project info
{{wiki(PageName)}}           # Enhanced wiki page link
{{twitter(username)}}        # Embed Twitter feed
{{iframe(http://example.com)}} # Embed external content
```

### Formatting Enhancements

```textile
{{div_start_tag(class=highlight)}}
Special content in a highlighted div
{{div_end_tag}}

{{page_break}}              # Add page break for printing

{{lastupdated_at}}          # Show last update time
{{lastupdated_by}}          # Show last editor
```

### Comments and Tagging

- **Add Comments**: Users can add hierarchical comments to any wiki page
- **Tag Pages**: Use the tagging interface to organize content
- **Vote on Content**: Rate pages using the voting system

## 🏗️ Development

### Running Tests

```bash
# Run all tests
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions

# Run with coverage
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions COVERAGE=true
```

### Build Scripts

The plugin includes comprehensive build scripts for CI/CD:

```bash
cd build-scripts
./install.sh    # Set up test environment
./build.sh      # Run full build process
./cleanup.sh    # Clean up after tests
```

### Database Support

Tested with:
- SQLite (development/testing)
- MySQL/MariaDB (production)
- PostgreSQL (production)

## 📁 Plugin Structure

```
redmine_wiki_extensions/
├── init.rb                 # Plugin registration and configuration
├── app/                    # Rails MVC structure
│   ├── controllers/        # Plugin controllers
│   ├── models/             # Data models (comments, tags, votes)
│   └── views/              # UI templates
├── lib/                    # Core functionality
│   ├── *_macro.rb          # Wiki macro implementations
│   ├── *_patch.rb          # Redmine core extensions
│   └── wiki_extensions_*.rb # Helper classes
├── config/
│   ├── routes.rb           # Plugin routes
│   └── locales/            # Internationalization files
├── db/migrate/             # Database migrations
├── assets/                 # Static assets (CSS, JS, images)
└── test/                   # Test suite
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch from `develop` (`git checkout -b feature/amazing-feature develop`)
3. Write tests for your changes
4. Ensure all tests pass
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. **Open a Pull Request against the `develop` branch** (not `main`/`master`)

**Important**: All pull requests must target the `develop` branch. PRs against other branches will be redirected.

### Development Guidelines

- Follow Redmine plugin development patterns
- Always include module enablement checks: `WikiExtensionsUtil.is_enabled?(@project)`
- Add appropriate permission checks
- Include tests for new functionality
- Update localization files for new features

## 📄 License

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

See [GPL.txt](GPL.txt) for full license details.

## 🙋‍♂️ Support

- **Issues**: [GitHub Issues](https://github.com/haru/redmine_wiki_extensions/issues)
- **Documentation**: [Project Wiki](https://www.r-labs.org/projects/r-labs/wiki/Wiki_Extensions_en)
- **Author**: [Haruyuki Iida](http://twitter.com/haru_iida)

## 📈 Changelog

### Version 1.0.2
- Compatible with Redmine 6.0+
- Improved test coverage
- Enhanced CI/CD pipeline
- Bug fixes and performance improvements

---

**Note**: This plugin is designed to work in production mode. For development and testing, please refer to the build scripts and testing documentation.


