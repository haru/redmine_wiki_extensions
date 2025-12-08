# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2025  Haruyuki Iida
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

require File.expand_path('../test_helper', __dir__)

class WikiExtensionsWikiEditTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :enabled_modules, :wikis,
    :wiki_pages, :wiki_contents, :wiki_content_versions, :attachments,
    :wiki_extensions_comments, :wiki_extensions_tags, :wiki_extensions_menus,
    :wiki_extensions_votes, :wiki_extensions_settings

  def setup
    @project = Project.find(1)
    @wiki = @project.wiki
    @page = WikiPage.find_by(id: 1)
    @page.content ||= WikiContent.create!(page: @page, text: 'test')

    @user = User.find_by(login: 'jsmith')
    @request.session[:user_id] = @user.id
    User.current = @user

    manager_role = Role.find_by(name: 'Manager')
    if manager_role
      needed_permissions = [
        :draft_view, :draft_create
      ]
      manager_role.permissions |= needed_permissions
      manager_role.save!
    end

    member = Member.find_or_initialize_by(project: @project, user: @user)
    member.roles << manager_role unless member.roles.include?(manager_role)
    member.save!

    EnabledModule.find_or_create_by!(project: @project, name: 'wiki_extensions')

    @controller = WikiController.new
  end

  test "should render wiki edit" do
    @request.session[:user_id] = User.current.id
    Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_comment'] = 'true'
    Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_tags'] = 'false'
    Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval'] = 'true'
    Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_draft_enabled'] = 'true'
    get :edit, params: { project_id: @project.id, id: @page.title }
    assert_response :success

    # 1. draft checkbox checked and disabled
    assert_select 'input[type=checkbox][name=status][id=status][value=draft][disabled=disabled][checked=checked]'
    # 2. tag with value
    assert_select 'p#wiki_extensions_tag_form'
    assert_select 'input[id=?][name=?][value=?]', 'extension_tags[0]', 'extension[tags][0]', 'MyString'
    # 3. commend required just in javascript
    assert_includes @response.body, 'span.textContent = " *"'

    # update page
    put :update, params: { project_id: @project.id, id: @page.title,
      content: {
        text: 'new text in textarea',
        comments: 'my comment'
      },
      extension: { tags: { '0' => 'MyString', '1' => 'MyString2', '2' => 'newtag' } },
      status_disabled: 'true',
      status: 'draft'}

    assert_response :redirect

    get :edit, params: { project_id: @project.id, id: @page.title }
    assert_response :success

    # all 3 tags, and new taxtarea
    assert_select 'input[id=?][name=?][value=?]', 'extension_tags[0]', 'extension[tags][0]', 'MyString'
    assert_select 'input[id=?][name=?][value=?]', 'extension_tags[1]', 'extension[tags][1]', 'MyString2'
    assert_select 'input[id=?][name=?][value=?]', 'extension_tags[2]', 'extension[tags][2]', 'newtag'
    assert_select 'textarea#content_text', text: /new text in textarea/

    @page.reload

    # draft status in db
    approval = WikiExtensionsApproval.for_wiki(@page.id, @page.content.version).first
    assert_equal 'draft', approval.status
  end

  test "should render wiki edit with no tags no draft checked" do
    @request.session[:user_id] = User.current.id
    Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_comment'] = 'true'
    Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_tags'] = 'true'
    Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval'] = 'false'
    Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_draft_enabled'] = 'true'
    get :edit, params: { project_id: @project.id, id: @page.title }
    assert_response :success

    # 1. draft checkbox  disabled=false checked=false
    assert_select 'input[type=checkbox][name=status][id=status][value=draft]' do |elements|
      el = elements.first
      assert_nil el['disabled'], 'not disabled'
      assert_nil el['checked'], 'not checked'
    end
    # 2. no tags found
    assert_select 'p#wiki_extensions_tag_form', false
  end
end
