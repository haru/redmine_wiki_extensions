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
  match "projects/:id/wiki_extensions/:action", :controller => "wiki_extensions", :via => [:get, :post]
  match "projects/:id/wiki_extensions_settings/:action", :controller => "wiki_extensions_settings", :via => [:get, :post, :put, :patch]
  match "/wiki_extentions/emoticon/:icon_name", :controller => "wiki_extensions", :action => "emoticon", :via => [:get], :as => "wiki_extensions_emoticon"
end
