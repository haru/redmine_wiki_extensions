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
class RenameWikiExtensionsTables < ActiveRecord::Migration
  def self.up
    rename_table :wiki_extensions_project_menus, :wiki_extensions_menus if table_exists? :wiki_extensions_project_menus
    rename_table :wiki_extensions_project_settings, :wiki_extensions_settings if table_exists? :wiki_extensions_project_settings
  end

  def self.down
    
  end
end
