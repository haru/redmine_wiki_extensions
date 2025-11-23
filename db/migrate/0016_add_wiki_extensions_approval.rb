# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2025  Haruyuki Iida
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
class AddWikiExtensionsApproval < ActiveRecord::Migration[4.2]
  def self.up
    create_table :wiki_extensions_approval do |t|
      t.references :wiki_page, null: false
      t.references :wiki_version, null: false
      t.references :author, null: false
      t.integer :status, null: false, default: 0
      t.text :note
      t.timestamps null: false
    end
    add_index :wiki_extensions_approval, :status, name: 'index_approval_on_status'
    add_index :wiki_extensions_approval, :author_id, name: 'index_approval_on_author'
    add_index :wiki_extensions_approval, [:wiki_page_id, :wiki_version_id], unique: true, name: 'index_approval_on_page_version', order: { wiki_version_id: :desc }

    create_table :wiki_extensions_approval_steps do |t|
      t.references :wiki_extensions_approval, null: false
      t.integer :step, null: false
      t.references :principal, polymorphic: true, null: false
      t.integer :step_type, null: false, default: 0
      t.text :note
      t.integer :status, null: false, default: 0
      t.timestamps null: false
    end
    add_index :wiki_extensions_approval_steps, :status, name: 'index_approval_steps_on_status'
    add_index :wiki_extensions_approval_steps, [:principal_type, :principal_id], name: 'index_approval_steps_on_principal'
    add_index :wiki_extensions_approval_steps, :wiki_extensions_approval_id, name: 'index_approval_steps_on_approval_id'
  end

  def self.down
    drop_table :wiki_extensions_approval
    drop_table :wiki_extensions_approval_steps
  end
end
