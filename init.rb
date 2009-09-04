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
require 'wiki_extensions_tags_macro'
require 'wiki_extensions_div_macro'
require 'wiki_extensions_recent_macro'
require 'wiki_extensions_lastupdated_by_macro'

Redmine::Plugin.register :redmine_wiki_extensions do
  name 'Redmine Wiki Extensions plugin'
  author 'Haruyuki Iida'
  description 'This is a Wiki Extensions plugin for Redmine'
  url "http://www.r-labs.org/wiki/r-labs/Wiki_Extensions_en" if respond_to?(:url)
  version '0.0.9'
  requires_redmine :version_or_higher => '0.8.3'

  project_module :wiki_extensions do
    permission :add_wiki_comment, {:wiki_extensions => [:add_comment]}
    permission :show_wiki_comment, {:wiki_extensions => [:show_comments]}, :public => true
    permission :show_wiki_tags, {:wiki_extensions => [:tag]}, :public => true
  end
  
end

