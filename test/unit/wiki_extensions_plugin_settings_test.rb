# frozen_string_literal: true

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

require File.expand_path('../test_helper', __dir__)

class WikiExtensionsSettingsTest < ActionDispatch::IntegrationTest
  fixtures :users

  def setup
    @admin = User.find(1)
    post '/login', params: { username: 'admin', password: 'admin' }
  end

  def test_settings_page_loads
    get '/settings/plugin/redmine_wiki_extensions'
    assert_response :success

    # all fields
    assert_select 'select[name="settings[wiki_extensions_settings_comment]"]'
    assert_select 'select[name="settings[wiki_extensions_settings_draft_enabled]"]'
    assert_select 'select[name="settings[wiki_extensions_settings_approval_enabled]"]'
    assert_select 'select[name="settings[wiki_extensions_settings_approval]"]'
    assert_select 'select[name="settings[wiki_extensions_settings_approval_version]"]'
    assert_select 'select[name="settings[wiki_extensions_settings_tags]"]'

    # all available options (Yes, No, Projects)
    assert_select 'option[value="true"]'
    assert_select 'option[value="false"]'
    assert_select 'option[value="project"]'
  end

  def test_update_all_settings
    post '/settings/plugin/redmine_wiki_extensions',
         params: {
           settings: {
             wiki_extensions_settings_comment: 'true',
             wiki_extensions_settings_draft_enabled: 'false',
             wiki_extensions_settings_approval_enabled: 'project',
             wiki_extensions_settings_approval: 'true',
             wiki_extensions_settings_approval_version: 'false',
             wiki_extensions_settings_tags: 'project'
           }
         }

    assert_redirected_to '/settings/plugin/redmine_wiki_extensions'
    follow_redirect!
    assert_response :success

    # check saved values
    assert_equal 'true', Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_comment']
    assert_equal 'false', Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_draft_enabled']
    assert_equal 'project', Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval_enabled']
    assert_equal 'true', Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval']
    assert_equal 'false', Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_approval_version']
    assert_equal 'project', Setting.plugin_redmine_wiki_extensions['wiki_extensions_settings_tags']
  end
end
