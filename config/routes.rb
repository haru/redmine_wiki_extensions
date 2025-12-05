# Wiki Extensions plugin for Redmine
# Copyright (C) 2012-2015  Haruyuki Iida
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

RedmineApp::Application.routes.draw do
  match "projects/:id/wiki_extensions/stylesheet", to: "wiki_extensions#stylesheet", via: [:get, :post], as: "wiki_extensions_stylesheet"
  scope "projects/:id/wiki_extensions" do
    post   "add_comment",     to: "wiki_extensions#add_comment"
    post   "reply_comment",   to: "wiki_extensions#reply_comment"
    delete "destroy_comment", to: "wiki_extensions#destroy_comment"
    get    "destroy_comment", to: "wiki_extensions#destroy_comment"
    post   "update_comment",  to: "wiki_extensions#update_comment"
    get    "tag",             to: "wiki_extensions#tag"
    get    "vote",            to: "wiki_extensions#vote"
    post   "vote",            to: "wiki_extensions#vote"
    get    "forward_wiki_page", to: "wiki_extensions#forward_wiki_page"
  end
  match "projects/:id/wiki_extensions_settings", to: "wiki_extensions_settings#update", via: [:patch, :post], as: "wiki_extensions"
  get "/wiki_extentions/emoticon/:icon_name", :controller => "wiki_extensions", :action => "emoticon", :as => "wiki_extensions_emoticon"
  match "projects/:id/wiki_extensions_approval/:title/:version", to: "wiki_extensions_approval#start_approval", via: [:get, :post], as: "wiki_extensions_approval"
  match 'projects/:id/wiki_extensions_approval/:title/:version/grant/:step_id', to: 'wiki_extensions_approval#grant_approval', via: [:get, :post],  as: 'wiki_extensions_grant_approval'
  match 'projects/:id/wiki_extensions_approval/:title/:version/forward/:step_id', to: 'wiki_extensions_approval#forward_approval', via: [:get, :post],  as: 'wiki_extensions_forward_approval'
end
