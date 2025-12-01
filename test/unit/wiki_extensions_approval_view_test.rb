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

class WikiExtensionsApprovalViewTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles, :wikis, :wiki_pages, :wiki_contents, :wiki_extensions_settings

  def setup
    @project = Project.find(1)
    @wiki = @project.wiki
    @page = WikiPage.find(11)

    @user = User.find_by(login: 'jsmith')
    @request.session[:user_id] = @user.id
    User.current = @user

    manager_role = Role.find_by(name: 'Manager')
    if manager_role
      needed_permissions = [
        :approval_start, :approval_grant, :approval_forward,
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

  test 'wiki page redirect to released version' do
    @request.session[:user_id] = User.current.id
    get :show, params: { project_id: @project.id, id: @page.title }
    # redirect to released version
    assert_response :redirect
    assert_redirected_to "/projects/1/wiki/#{@page.title}/2"
  end

  test 'wiki page show released version' do
    @request.session[:user_id] = User.current.id
    get :show, params: { project_id: @project.id, id: @page.title, version: 2 }
    assert_response :success
    # link to draft version, under contextual
    assert_select 'div#content div.contextual a.icon.icon-workflows[href*="wiki/Page_with_sections/3"]'
    # closed badge
    assert_select 'div#content div.contextual span.badge.badge-status-closed'
  end

  test 'wiki page show pending version and sidebar' do
    @request.session[:user_id] = User.current.id
    get :show, params: { project_id: @project.id, id: @page.title, version: 3 }
    assert_response :success
    # link to draft version, under contextual
    assert_select 'div#content div.contextual a.icon.icon-workflows[href*="wiki/Page_with_sections/2"]'
    # open badge
    assert_select 'div#content div.contextual span.badge.badge-status-open'
    # workflow approval icon
    assert_select 'div#content div.contextual a.icon.icon-workflows[href*="wiki_extensions_approval/Page_with_sections/3"]'
    # sidebar
    assert_select 'div#sidebar div#sidebar-wrapper div#approval'
  end
end
