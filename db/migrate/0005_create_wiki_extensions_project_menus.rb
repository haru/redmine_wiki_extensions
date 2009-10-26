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
class CreateWikiExtensionsProjectMenus < ActiveRecord::Migration
  def self.up
    create_table :wiki_extensions_menus do |t|

      t.column :project_id, :integer
      t.column :menu_no, :integer
      t.column :page_name, :string
      t.column :title, :string
      t.column :enabled, :boolean

    end
  end

  def self.down
    drop_table :wiki_extensions_menus
  end
end
