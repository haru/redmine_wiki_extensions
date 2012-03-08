# Code Review plugin for Redmine
# Copyright (C) 2009  Haruyuki Iida
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
require File.dirname(__FILE__) + '/../test_helper'

class WikiExtensionsSettingsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :enabled_modules, :wikis, 
    :wiki_pages, :wiki_contents, :wiki_content_versions, :attachments,
    :wiki_extensions_comments, :wiki_extensions_tags, :wiki_extensions_menus,
    :wiki_extensions_votes, :wiki_extensions_settings

  def setup
    @controller = WikiExtensionsSettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.env["HTTP_REFERER"] = '/'
    @request.session[:user_id] = 1
    @project = Project.find(1)
    
    enabled_module = EnabledModule.new
    enabled_module.project_id = 1
    enabled_module.name = 'wiki_extensions'
    enabled_module.save
  end

  context "update" do
    should "save settings." do
      menus = {}
      menus[0] = {:enabled => 'true',:menu_no => 1, :title => 'my_title', :page_name => 'my_page_name'}
      menus[1] = {:enabled => 'true',:menu_no => 2, :title => 'my_title2', :page_name => 'my_page_name2'}
      post :update, :setting => {:auto_preview_enabled => 1},
        :menus => menus, :id => @project
      assert_response :redirect
      setting = WikiExtensionsSetting.find_or_create @project.id
      assert_equal(true, setting.auto_preview_enabled)
      menus = setting.menus
      assert_equal(5, menus.length)
      assert(menus[0].enabled)
      assert_equal('my_title', menus[0].title)
      assert_equal('my_page_name', menus[0].page_name)
      assert(menus[1].enabled)
      assert_equal('my_title2', menus[1].title)
      assert_equal('my_page_name2', menus[1].page_name)
    end
  end
  
end
