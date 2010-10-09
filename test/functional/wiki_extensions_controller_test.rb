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

class WikiExtensionsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :enabled_modules, :wikis, 
    :wiki_pages, :wiki_contents, :wiki_content_versions, :attachments,
    :wiki_extensions_comments, :wiki_extensions_tags, :wiki_extensions_menus,
    :wiki_extensions_votes

  def setup
    @controller = WikiExtensionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.env["HTTP_REFERER"] = '/'
    @project = Project.find(1)
    @wiki = @project.wiki
    @page_name = 'macro_test'
    @page = @wiki.find_or_new_page(@page_name)
    @page.content = WikiContent.new
    @page.content.text = "{{comments}}"
    @page.save!
    side_bar = @wiki.find_or_new_page('SideBar')
    side_bar.content = WikiContent.new
    side_bar.content.text = 'test'
    side_bar.save!
    style_sheet = @wiki.find_or_new_page('StyleSheet')
    style_sheet.content = WikiContent.new
    style_sheet.content.text = 'test'
    style_sheet.save!
    enabled_module = EnabledModule.new
    enabled_module.project_id = 1
    enabled_module.name = 'wiki_extensions'
    enabled_module.save
  end

  def test_add_comment
    @request.session[:user_id] = 1
    post :add_comment, :id => 1, :wiki_page_id => @page.id, :comment => 'aaa'
    assert_response :redirect
  end

  def test_tag
    @request.session[:user_id] = 1
    get :tag, :id => 1, :tag_id => 1
    #assert assigns[:tag]
  end

  def test_destroy_comment
    comment = WikiExtensionsComment.new
    comment.wiki_page_id = @page.id
    comment.user_id = 1
    comment.comment = "aaa"
    comment.save!
    @request.session[:user_id] = 1
    post :destroy_comment, :id => 1, :comment_id => comment.id
    assert_response :redirect
    comment = WikiExtensionsComment.find(:first, :conditions => ['id = ?', comment.id])
    assert_nil(comment)
  end

  def test_update_comment
    comment = WikiExtensionsComment.new
    comment.wiki_page_id = @page.id
    comment.user_id = 1
    comment.comment = "aaa"
    comment.save!
    message = "newcomment"
    @request.session[:user_id] = 1
    post :update_comment, :id => 1, :comment_id => comment.id, :comment => message
    assert_response :redirect
    comment = WikiExtensionsComment.find(comment.id)
    assert_equal(message, comment.comment)
  end

  def test_forwad_wiki_page
    @request.session[:user_id] = 1
    get :forward_wiki_page, :id => 1, :menu_id => 1
    assert_response :redirect
  end

  context "vote" do
    should "success if new vote." do
      @request.session[:user_id] = 1
      count = WikiExtensionsVote.find(:all).length
      post :vote, :id => 1, :target_class_name => 'Project', :target_id => 1,
        :key => 'aaa', :url => 'http://localhost:3000'
      assert_equal(count + 1, WikiExtensionsVote.find(:all).length)
      assert_response :success
    end
  end
end
