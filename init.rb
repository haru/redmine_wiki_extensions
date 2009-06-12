# Wiki Extensions plugin for Redmine
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
require 'redmine'
require 'wiki_extensions_application_hooks'
require 'wiki_extensions_wiki_page_patch'
require 'wiki_extensions_footnote'
require 'wiki_extensions_comments'
require 'wiki_extensions_wiki_macro'
require 'wiki_extensions_project_macro'
require 'wiki_extensions_wiki_controller_patch'
require 'wiki_extensions_new_macro'

Redmine::Plugin.register :redmine_wiki_extensions do
  name 'Redmine Wiki Extensions plugin'
  author 'Haruyuki Iida'
  description 'This is a plugin for Redmine'
  version '0.0.2'

  project_module :wiki_extensions do
    permission :add_wiki_comment, {:wiki_extensions => [:add_comment]}
    permission :show_wiki_comment, {:wiki_extensions => [:show_comments]}, :public => true
    #menu :project_menu, :wiki_extensions, { :controller => 'wiki_extensions', :action => 'add_comment' }, :caption => 'Wiki Extensions', :param => :id
  end
  
end

