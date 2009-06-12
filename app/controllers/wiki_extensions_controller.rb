class WikiExtensionsController < ApplicationController
  unloadable
  before_filter :find_project, :authorize, :find_user

  def add_comment

    comment = WikiExtensionsComment.new
    comment.wiki_page_id = params[:wiki_page_id].to_i
    comment.user_id = @user.id
    comment.comment = params[:comment]
    comment.save
    page = WikiPage.find(comment.wiki_page_id)
    redirect_to :controller => 'wiki', :action => 'index', :id => @project, :page => page.title
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
