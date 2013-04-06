# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2013  Haruyuki Iida
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
require 'redmine'
require 'application_helper'
class WikiExtensionsApplicationHooks < Redmine::Hook::ViewListener
  include ApplicationHelper

  render_on :view_layouts_base_html_head, :partial => 'wiki_extensions/html_header'
  render_on :view_layouts_base_body_bottom, :partial => 'wiki_extensions/body_bottom'
    
end

def add_wiki_auto_preview(context)
  project = context[:project]
  setting = WikiExtensionsSetting.find_or_create(project.id)
  return '' unless setting.auto_preview_enabled
  request = context[:request]
  params = request.parameters if request
  page_name = params[:id] if params
  url = url_for(:controller => 'wiki', :action => 'preview', :id => page_name, :project_id => project)
  o = ''
  o << javascript_tag("setWikiAutoPreview('#{url}');")
  return o
end

def add_messages_auto_preview(context)
  project = context[:project]
  setting = WikiExtensionsSetting.find_or_create(project.id)
  return '' unless setting.auto_preview_enabled
  request = context[:request]
  params = request.parameters if request
  board = params[:board_id] if params
  url = url_for :controller => 'messages', :action => 'preview', :board_id => board
  o = ''
  o << javascript_tag("setMessagesAutoPreview('#{url}');")
  return o
end

def add_boards_auto_preview(context)
  project = context[:project]
  setting = WikiExtensionsSetting.find_or_create(project.id)
  return '' unless setting.auto_preview_enabled
  return '' unless @board
  return '' unless @board.id
  url = url_for :controller => 'messages', :action => 'preview', :board_id => @board
  o = ''
  o << javascript_tag("setBoardsAutoPreview('#{url}');")
  return o
end