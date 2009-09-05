class CreateWikiExtensionsProjectMenus < ActiveRecord::Migration
  def self.up
    create_table :wiki_extensions_project_menus do |t|

      t.column :project_id, :integer
      t.column :menu_no, :integer
      t.column :page_name, :string
      t.column :title, :string
      t.column :enabled, :boolean

    end
  end

  def self.down
    drop_table :wiki_extensions_project_menus
  end
end
