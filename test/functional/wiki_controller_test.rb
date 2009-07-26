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

class WikiControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :enabled_modules, :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions, :attachments

  def setup
    @controller = WikiController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.env["HTTP_REFERER"] = '/'
    project = Project.find(1)
    @wiki = project.wiki
    @page_name = 'macro_test'
    @page = @wiki.find_or_new_page(@page_name)
    @page.content = WikiContent.new
    @page.content.text = 'test'
    @page.save!
    enabled_module = EnabledModule.new
    enabled_module.project_id = 1
    enabled_module.name = 'wiki_extensions'
    enabled_module.save

  end

  def test_comment_form
    text = '{{comment_form}}'
    text << "\n"
    text << "{{comments}}"
    setContent(text)
    @request.session[:user_id] = 1
    get :index, :id => 1, :page => @page_name
    assert_response :success

  end

  def test_div
    text = "{{div_start_tag(foo)}}\n"
    text << "{{div_end_tag}}\n"
    text << "{{div_start_tag(var, hoge)}}\n"
    text << "{{div_end_tag}}\n"
    setContent(text)
    @request.session[:user_id] = 1
    get :index, :id => 1, :page => @page_name
    assert_response :success

  end

  def test_footnote
    text = "{{fn(aaa,bbb)}}\n"
    text << "{{fn(ccc,ddd)}}\n"
    text << "{{fnlist}}\n"
    setContent(text)
    @request.session[:user_id] = 1
    get :index, :id => 1, :page => @page_name
    assert_response :success

  end

  private

  def setContent(text)
    page = @wiki.find_or_new_page(@page_name)
    page.content.text = text
    page.save!
    page.content.save!
  end
end
