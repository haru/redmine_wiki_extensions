# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2024  Haruyuki Iida
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

class WikiExtensionsController < ApplicationController
  menu_item :wiki
  before_action :find_project, :find_user
  before_action :authorize, except: [:stylesheet, :emoticon]

  def add_comment
    comment = WikiExtensionsComment.new
    comment.wiki_page_id = params[:wiki_page_id].to_i
    comment.user_id = @user.id
    comment.comment = params[:comment]
    comment.save
    page = WikiPage.find(comment.wiki_page_id)
    # Send email-notification to watchers of wiki page
    WikiExtensionsCommentsMailer.deliver_wiki_commented(comment, page) if Setting.notified_events.include? "wiki_comment_added"
    redirect_to :controller => "wiki", :action => "show", :project_id => @project, :id => page.title
  end

  def reply_comment
    comment = WikiExtensionsComment.new
    comment.parent_id = params[:comment_id].to_i
    comment.wiki_page_id = params[:wiki_page_id].to_i
    comment.user_id = @user.id
    comment.comment = params[:reply]
    comment.save
    page = WikiPage.find(comment.wiki_page_id)
    # Send email-notification to watchers of wiki page
    WikiExtensionsCommentsMailer.deliver_wiki_commented(comment, page) if Setting.notified_events.include? "wiki_comment_added"
    redirect_to :controller => "wiki", :action => "show", :project_id => @project, :id => page.title
  end

  def tag
    tag_id = params[:tag_id].to_i
    @tag = WikiExtensionsTag.find(tag_id)
  end

  def forward_wiki_page
    menu_id = params[:menu_id].to_i
    menu = WikiExtensionsMenu.find_or_create(@project.id, menu_id)
    redirect_to :controller => "wiki", :action => "show", :project_id => @project, :id => menu.page_name
  end

  def destroy_comment
    comment_id = params[:comment_id].to_i
    comment = WikiExtensionsComment.find(comment_id)
    unless User.current.admin or User.current.id == comment.user.id
      render_403
      return false
    end

    page = WikiPage.find(comment.wiki_page_id)
    comment.destroy
    redirect_to :controller => "wiki", :action => "show", :project_id => @project, :id => page.title
  end

  def update_comment
    comment_id = params[:comment_id].to_i
    comment = WikiExtensionsComment.find(comment_id)
    unless User.current.admin or User.current.id == comment.user.id
      render_403
      return false
    end

    page = WikiPage.find(comment.wiki_page_id)
    comment.comment = params[:comment]
    comment.save
    redirect_to :controller => "wiki", :action => "show", :project_id => @project, :id => page.title
  end

  def vote
    target_class_name = params[:target_class_name]
    target_id = params[:target_id].to_i
    key = params[:key]
    vote = WikiExtensionsVote.find_or_create(target_class_name, target_id, key)
    session[:wiki_extension_voted] = Hash.new unless session[:wiki_extension_voted]
    unless session[:wiki_extension_voted][vote.id]
      vote.countup
      vote.save!
      session[:wiki_extension_voted][vote.id] = 1
    end

    render :inline => " #{vote.count}"
  end

  def stylesheet
    stylesheet = WikiPage.find_by(wiki_id: @project.wiki.id, title: "StyleSheet")
    unless stylesheet
      render_404
      return
    end

    unless stylesheet.visible?
      render_403
      return
    end
    render plain: stylesheet.content.text, content_type: "text/css"
  end

  def emoticon
    icon_name = params[:icon_name]
    icon_name += ".#{params[:format]}" if params[:format].present?
    directory = File.expand_path(File.dirname(__FILE__) + "/../../assets/images/")
    icon_path = File.join(directory, icon_name)
    # icon_pathが示すPNGファイルのバイナリデータをクライアントに返す
    if File.exist?(icon_path)
      send_file icon_path, type: "image/png", disposition: "inline"
    else
      render_404
    end
  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id]) unless params[:id].blank?
  end

  def find_user
    @user = User.current
  end
end
