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
  fixtures :projects, :users, :roles, :members, :enabled_modules, :wikis, 
    :wiki_pages, :wiki_contents, :wiki_content_versions, :attachments,
    :wiki_extensions_comments, :wiki_extensions_tags

  def setup
    @controller = WikiController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.env["HTTP_REFERER"] = '/'
    @project = Project.find(1)
    @wiki = @project.wiki
    @page_name = 'macro_test'
    @page = @wiki.find_or_new_page(@page_name)
    @page.content = WikiContent.new
    @page.content.text = 'test'
    @page.save!
    side_bar = @wiki.find_or_new_page('SideBar')
    side_bar.content = WikiContent.new
    side_bar.content.text = 'test'
    side_bar.save!
    footer = @wiki.find_or_new_page('Footer')
    footer.content = WikiContent.new
    footer.content.text = 'test'
    footer.save!
    style_sheet = @wiki.find_or_new_page('StyleSheet')
    style_sheet.content = WikiContent.new
    style_sheet.content.text = 'test'
    style_sheet.save!
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
    get :show, :project_id => 1, :id => @page_name
    assert_response :success

  end

  def test_comments
    text = "{{comments}}"
    setContent(text)
    comment = WikiExtensionsComment.new
    comment.wiki_page_id = @page.id
    comment.user_id = 1
    comment.comment = "aaa"
    comment.save!
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success
  end

  def test_div
    text = "{{div_start_tag(foo)}}\n"
    text << "{{div_end_tag}}\n"
    text << "{{div_start_tag(var, hoge)}}\n"
    text << "{{div_end_tag}}\n"
    setContent(text)
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success

  end

  def test_footnote
    text = "{{fn(aaa,bbb)}}\n"
    text << "{{fn(ccc,ddd)}}\n"
    text << "{{fnlist}}\n"
    setContent(text)
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success

  end

  def test_new
    text = "{{new(#{Date.today.to_s})}}\n"
    text << "{{new(#{(Date.today - 1).to_s})}}\n"
    text << "{{new(#{(Date.today - 2).to_s})}}\n"
    text << "{{new(2009-03-01, 4)}}\n"
    setContent(text)
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success
  end

  def test_project
    text = "{{project(#{@project.name})}}\n"
    text << "{{project(#{@project.id})}}\n"
    text << "{{project(#{@project.name}, hoge)}}\n"
    text << "{{project(#{@project.id}), bar}}\n"
    setContent(text)
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success
  end

  def test_tags
    page = @wiki.find_or_new_page(@page_name)
    page.tags << WikiExtensionsTag.find(1)
    page.save!
    text = "{{tags}}\n"
    text << "{{tagcloud}}\n"
    setContent(text)
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success
  end

  def test_wiki
    text = ''
    text << "{{wiki(#{@project.name}, #{@page_name})}}\n"
    text << "{{wiki(#{@project.name}, #{@page_name}, foo)}}\n"
    text << "{{wiki(#{@project.id}, #{@page_name})}}\n"
    text << "{{wiki(#{@project.id}, #{@page_name}, bar)}}\n"
    setContent(text)
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success
  end

  def test_edit
    @request.session[:user_id] = 1
    get :edit, :project_id => 1, :id => @page_name
    assert_response :success

    post :edit, :project_id => 1, :id => @page_name, :content => {:text => 'aaa'},
      :extension => {:tags =>{"0" => "aaa", "1" => "bbb"}}
    assert_response :success
  end

  def test_recent
    text = ''
    text << "{{recent}}\n"
    text << "{{recent(10)}}\n"
    
    setContent(text)
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success
  end

  def test_lastupdated_by
    text = ''
    text << "{{lastupdated_by}}\n"

    setContent(text)
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success
  end

  def test_lastupdated_at
    text = ''
    text << "{{lastupdated_at}}\n"

    setContent(text)
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success
  end

  def test_iframe
    text = ''
    text << "{{iframe(http://google.com, 200, 400)}}\n"
    text << "{{iframe(http://google.com, 200, 400, no)}}\n"

    setContent(text)
    @request.session[:user_id] = 1
    get :show, :project_id => 1, :id => @page_name
    assert_response :success
  end

  context "count" do
    should "success" do
      text = ''
      text << "{{count}}\n"

      setContent(text)
      @request.session[:user_id] = 1
      get :show, :project_id => 1, :id => @page_name
      assert_response :success
    end
  end

  context "show_count" do
    should "success" do
      text = ''
      text << "{{show_count}}\n"

      setContent(text)
      @request.session[:user_id] = 1
      get :show, :project_id => 1, :id => @page_name
      assert_response :success
    end
  end

  context "popularity" do
    should "success if there is no count data" do
      text = ''
      text << "{{popularity}}\n"

      setContent(text)
      @request.session[:user_id] = 1
      get :show, :project_id => 1, :id => @page_name
      assert_response :success
    end

    should "success if there is count data" do
      text = ''
      text << "{{count}}\n"
      text << "{{popularity}}\n"

      setContent(text)
      @request.session[:user_id] = 1
      get :show, :project_id => 1, :id => @page_name
      assert_response :success
    end
  end

  context "vote" do
    should "success" do
      text = ''
      text << "{{vote(aaa)}}\n"

      setContent(text)
      @request.session[:user_id] = 1
      get :show, :project_id => 1, :id => @page_name
      assert_response :success
    end
  end

  context "show_vote" do
    should "success" do
      text = ''
      text << "{{show_vote(aaa)}}\n"

      setContent(text)
      @request.session[:user_id] = 1
      get :show, :project_id => 1, :id => @page_name
      assert_response :success
    end
  end

  context "twitter" do
    should "success" do
      text = ''
      text << "{{twitter(haru_iida)}}\n"

      setContent(text)
      @request.session[:user_id] = 1
      get :show, :project_id => 1, :id => @page_name
      assert_response :success
    end
  end

  context "taggedpages" do
    should "success" do
      text = ''
      text << "{{taggedpages(aaa)}}\n"

      setContent(text)
      @request.session[:user_id] = 1
      get :show, :project_id => 1, :id => @page_name
      assert_response :success
    end
  end

  context "ref_issues" do
    should "success" do
      text = ''
      text << "{{ref_issues}}\n"
      text << "{{ref_issues(-rw=test,project,tracker,subject,status,author,assigned,created,updated)}}\n"

      setContent(text)
      @request.session[:user_id] = 1
      get :show, :project_id => 1, :id => @page_name
      assert_response :success
    end
  end

  private

  def setContent(text)
    page = @wiki.find_or_new_page(@page_name)
    page.content.text = text
    page.content.author_id = 1
    page.save!
    page.content.save!
  end
end
