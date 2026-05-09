---
applyTo: "test/**/*.rb"
---

# Test Conventions

Tests run inside Redmine's test harness — never standalone. Run from `/usr/local/redmine`:

```bash
bundle exec rake redmine:plugins:test NAME=redmine_wiki_extensions TEST=plugins/redmine_wiki_extensions/test/path/to/file.rb
```

## File Placement

| Test type | Directory | Base class |
|-----------|-----------|------------|
| Model / unit | `test/unit/` | `ActiveSupport::TestCase` |
| Controller / functional | `test/functional/` | `ActionController::TestCase` |

## Fixture Declarations

Plugin fixtures use the `wiki_extensions_` prefix. Declare only what the test needs:

```ruby
fixtures :projects, :users, :roles, :members, :enabled_modules, :wikis,
         :wiki_pages, :wiki_contents,
         :wiki_extensions_comments, :wiki_extensions_tags
```

**Plugin-only fixtures**: `wiki_extensions_comments`, `wiki_extensions_counts`, `wiki_extensions_menus`, `wiki_extensions_settings`, `wiki_extensions_tag_relations`, `wiki_extensions_tags`, `wiki_extensions_votes`.

## Enable the Plugin Module

Controller tests require the `wiki_extensions` module to be active:

```ruby
def setup
  EnabledModule.create!(project_id: 1, name: 'wiki_extensions')
end
```

## `shoulda` Style

Use `context`/`should` blocks for grouped assertions:

```ruby
context "find_or_create" do
  setup do
    @project = Project.find(1)
  end

  should "return existing record" do
    obj = MyModel.find_or_create(@project.id)
    assert_equal @project.id, obj.project_id
  end
end
```

Plain `def test_*` methods are also acceptable for simple cases.

## Controller Test Setup Pattern

```ruby
def setup
  @controller = WikiExtensionsController.new
  @request    = ActionController::TestRequest.create(self.class.controller_class)
  @request.env['HTTP_REFERER'] = '/'
  @project = Project.find(1)
  EnabledModule.create!(project_id: 1, name: 'wiki_extensions')
end
```

Authenticate with `@request.session[:user_id] = 1` (admin) before requests.
